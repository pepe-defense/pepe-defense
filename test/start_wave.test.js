import { expect } from 'chai'
import { ethers } from 'hardhat'

import extract_event from './util/extract_event.js'
import parse_struct from './util/parse_struct.js'

const to_number = bn => bn.toNumber()

export default deploy => () => {
  // it('should prevent playing if the game is finished', async () => {
  //   const { tony } = await deploy()
  //   await tony.contract.new_game()
  //   await tony.contract.place_towers([12, 22, 62, 72], 99999999, 100, 1)

  //   await Promise.all(
  //     Array.from({ length: 9 }).map(() => tony.contract.start_wave())
  //   )

  //   await expect(tony.contract.start_wave()).to.be.revertedWith(
  //     'There is no more waves'
  //   )
  // })

  it('should loose the game if the mobs are too powerful', async () => {
    const { tony } = await deploy()
    const expected = {
      player: tony.address,
      wave: 2,
      won: false,
    }

    await tony.contract.new_game()

    await Promise.all(
      Array.from({ length: 2 }).map(() => tony.contract.start_wave())
    )

    const result = await tony.contract.start_wave().then(extract_event)
    expect(result).to.deep.equalInAnyOrder(expected)
  })

  it('should win the game if there is enough towers', async () => {
    const { tony } = await deploy()
    const expected = {
      player: tony.address,
      wave: 1,
      won: true,
    }

    await tony.contract.new_game()
    await tony.contract.place_towers([11, 12], 200, 2, 2)

    const result = await tony.contract.start_wave().then(extract_event)
    expect(result).to.deep.equalInAnyOrder(expected)
  })

  it('should provide a deterministic tick count', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()

    expect((await tony.contract.s_game(tony.address)).tick.toNumber()).to.equal(
      210
    )
  })

  it('should remove life if a mob is not kiled', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()

    expect((await tony.contract.s_game(tony.address)).life.toNumber()).to.equal(
      9
    )
  })

  it('should attribute score if the wave is won', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.place_towers([11, 12], 200, 10, 1)
    await tony.contract.start_wave()

    const days_since_deployed_1 = 0
    const days_since_deployed_2 = 5

    // going forward in time
    await ethers.provider.send('evm_mine', [
      days_since_deployed_2 * 24 * 60 * 60 + Date.now() / 1000,
    ])

    const { score: score_1 } = await tony.contract
      .s_game(tony.address)
      .then(parse_struct)
    const { won } = await tony.contract.start_wave().then(extract_event)
    const { score: score_2 } = await tony.contract
      .s_game(tony.address)
      .then(parse_struct)
    const total_score = await tony.contract.total_score().then(to_number)

    const tower_cost = 200
    const life = 20
    const expected_score_1 = tower_cost * life * 1 - days_since_deployed_1
    const expected_score_2 = tower_cost * life * 2 - days_since_deployed_2

    // eslint-disable-next-line no-unused-expressions
    expect(won).to.be.true
    expect(score_1).to.equal(expected_score_1)
    expect(score_2).to.equal(score_1 + expected_score_2)
    expect(total_score).to.equal(expected_score_1 + expected_score_2)
    expect(total_score).to.equal(score_2)
  })
}
