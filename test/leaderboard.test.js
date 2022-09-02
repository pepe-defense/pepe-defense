import { expect } from 'chai'

import parse_struct from './util/parse_struct.js'

export default deploy => async () => {
  it('Should add in the top player', async () => {
    const { tony } = await deploy()

    await tony.contract.new_game()
    await tony.contract.place_towers([11, 12], 10, 3, 3)
    await tony.contract.start_wave()
    await tony.contract.leaderboard_set_username('Tony')

    const expected = [
      {
        user: tony.address,
        score: 4000,
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

    await tony.contract.new_game()
    await bruce.contract.new_game()
    await tony.contract.place_towers([11, 12], 10, 3, 3)
    await bruce.contract.place_towers([11], 5, 3, 3)
    await tony.contract.start_wave()
    await bruce.contract.start_wave()
    await tony.contract.start_wave()
    await tony.contract.leaderboard_set_username('Tony')
    await bruce.contract.leaderboard_set_username('Bruce')

    const expected = [
      {
        user: tony.address,
        score: 12000,
        username: 'Tony',
      },
      {
        user: bruce.address,
        score: 2000,
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
