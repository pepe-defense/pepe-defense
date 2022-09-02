import { expect } from 'chai'

import extract_event from './util/extract_event.js'

const number = bn => bn.toNumber()

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

  it.only('prevent starting a wave if the game is lost', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()
    await tony.contract.start_wave()
    await expect(tony.contract.start_wave()).to.be.revertedWith(
      'The game is over'
    )
  })

  it('should make sure the game was created first', async () => {
    const { tony } = await deploy()
    await expect(tony.contract.start_wave()).to.be.revertedWith(
      'The game must be started'
    )
  })

  it('should loose the game if the mobs are too powerful', async () => {
    const { tony } = await deploy()
    const expected = {
      player: tony.address,
      wave: 2,
      won: false,
    }

    await tony.contract.new_game()
    await tony.contract.start_wave()

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

    expect(await tony.contract.get_tick().then(number)).to.equal(210)
  })

  it('should remove life if a mob is not kiled', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()

    expect(await tony.contract.get_life()).to.equal(9)
  })

  it('should attribute score if the wave is won', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.place_towers([11, 12], 200, 10, 1)
    await tony.contract.start_wave()

    const { score: score_1 } = await tony.contract.get_score().then(number)
    const { won } = await tony.contract.start_wave().then(extract_event)
    const { score: score_2 } = await tony.contract.get_score().then(number)
    const total_score = await tony.contract.total_score().then(number)

    const tower_cost = 200
    const life = 20
    const expected_score_1 = tower_cost * life * 1
    const expected_score_2 = tower_cost * life * 2

    // eslint-disable-next-line no-unused-expressions
    expect(won).to.be.true
    expect(score_1).to.equal(expected_score_1)
    expect(score_2).to.equal(score_1 + expected_score_2)
    expect(total_score).to.equal(expected_score_1 + expected_score_2)
    expect(total_score).to.equal(score_2)
  })
}
