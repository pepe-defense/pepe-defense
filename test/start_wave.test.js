import { expect } from 'chai'

import extract_event from './util/extract_event.js'

const number = bn => bn.toNumber()
const DEFAULT_TOWER = {
  damage: 200,
  range: 2,
  fire_rate: 2,
  last_fired: 0,
  score_value: 100,
}

export default deploy => () => {
  it('should prevent playing if the game is finished', async () => {
    const { tony } = await deploy()
    const tower = {
      ...DEFAULT_TOWER,
      damage: 99999999,
      range: 100,
      fire_rate: 5,
    }
    await tony.contract.new_game()

    await tony.contract.set_towers([{ ...tower, cell_id: 99 }])

    await Promise.all(
      Array.from({ length: 19 }).map(() => tony.contract.start_wave())
    )

    await expect(tony.contract.start_wave()).to.be.revertedWith(
      'There is no more waves'
    )
  }).timeout(100000)

  it('prevent starting a wave if the game is lost', async () => {
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
      life: 0,
      tick: 368,
      won: false,
      score: 0,
    }

    await tony.contract.new_game()
    await tony.contract.start_wave()

    const { player, wave, life, tick, won, score } = await tony.contract
      .start_wave()
      .then(extract_event)
    expect({ player, wave, life, tick, won, score }).to.deep.equalInAnyOrder(
      expected
    )
  })

  it('should win the wave if there is enough towers', async () => {
    const { tony } = await deploy()

    await tony.contract.new_game()
    await tony.contract.set_towers([{ ...DEFAULT_TOWER, cell_id: 107 }])

    await tony.contract.start_wave()
    const result = await tony.contract.start_wave().then(extract_event)
    // eslint-disable-next-line no-unused-expressions
    expect(result.won).to.be.true
  })

  it('should remove life if a mob is not killed', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()

    expect(await tony.contract.get_life()).to.equal(5)
  })

  it('should attribute score if the wave is won', async () => {
    const { tony, bruce } = await deploy()
    const towers = [
      { ...DEFAULT_TOWER, range: 10, cell_id: 101 },
      { ...DEFAULT_TOWER, range: 10, cell_id: 73 },
    ]
    await bruce.contract.new_game()
    await bruce.contract.set_towers(towers)
    const { score: bruce_score } = await bruce.contract
      .start_wave()
      .then(extract_event)

    await tony.contract.new_game()
    await tony.contract.set_towers(towers)
    await tony.contract.start_wave()

    const score_1 = await tony.contract.get_score().then(number)
    const tick_1 = await tony.contract.get_total_tick().then(number)
    const life_1 = await tony.contract.get_life()

    const { won, score, life } = await tony.contract
      .start_wave()
      .then(extract_event)

    const score_2 = await tony.contract.get_score().then(number)
    const tick_2 = await tony.contract.get_total_tick().then(number)
    const life_2 = await tony.contract.get_life()
    const total_score = await tony.contract.get_total_score().then(number)

    const towers_value = towers.reduce(
      (acc, { score_value }) => acc + score_value,
      0
    )
    const expected_score_1 = towers_value * life_1 * 1 * 1 - tick_1
    const expected_score_2 =
      expected_score_1 + towers_value * life_2 * 2 * 2 - tick_2

    // eslint-disable-next-line no-unused-expressions
    expect(won).to.be.true
    expect(score_1).to.equal(expected_score_1)
    expect(score_2).to.equal(expected_score_2)
    expect(life).to.be.equal(life_2)
    expect(score).to.equal(expected_score_2)
    expect(total_score).to.equal(bruce_score + expected_score_2)
    expect(total_score).to.equal(score_2 + bruce_score)
  })
}
