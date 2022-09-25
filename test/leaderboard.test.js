import { expect } from 'chai'

import parse_struct from './util/parse_struct.js'

const DEFAULT_TOWER = {
  damage: 10,
  range: 3,
  fire_rate: 3,
  last_fired: 0,
  score_value: 100,
}

export default deploy => async () => {
  it('Should add in the top player', async () => {
    const { tony } = await deploy()
    const towers = [
      { ...DEFAULT_TOWER, cell_id: 81 },
      { ...DEFAULT_TOWER, cell_id: 99 },
    ]

    await tony.contract.new_game()
    await tony.contract.set_towers(towers)
    await tony.contract.start_wave()
    await tony.contract.set_username('Tony')

    const expected = [
      {
        user: tony.address,
        score: 1987,
        username: 'Tony',
      },
    ]
    expect(
      [...(await tony.contract.get_leaderboard())]
        .map(parse_struct)
        .filter(({ score }) => !!score)
    ).to.deep.equalInAnyOrder(expected)
  })

  it('Should shift players when a better score is found', async () => {
    const { tony, bruce } = await deploy()
    const tony_towers = [
      { ...DEFAULT_TOWER, cell_id: 81 },
      { ...DEFAULT_TOWER, cell_id: 99 },
    ]
    const bruce_towers = [{ ...DEFAULT_TOWER, damage: 5, cell_id: 101 }]

    await tony.contract.new_game()
    await bruce.contract.new_game()
    await tony.contract.set_towers(tony_towers)
    await bruce.contract.set_towers(bruce_towers)
    await tony.contract.start_wave()
    await bruce.contract.start_wave()
    await tony.contract.start_wave()
    await tony.contract.set_username('Tony')
    await bruce.contract.set_username('Bruce')

    const expected = [
      {
        user: tony.address,
        score: 9962,
        username: 'Tony',
      },
      {
        user: bruce.address,
        score: 957,
        username: 'Bruce',
      },
    ]
    expect(
      [...(await tony.contract.get_leaderboard())]
        .map(parse_struct)
        .filter(({ score }) => !!score)
    ).to.deep.equal(expected)
  })
}
