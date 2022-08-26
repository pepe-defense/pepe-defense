import { expect } from 'chai'

import parse_struct from './parse_struct.js'

export default deploy => () => {
  it(`should set a specific state to the player's game`, async () => {
    const expected_state = {
      wave: 1,
      life: 20,
      wave_started: false,
      finished: false,
      tick: 0,
      mobs_length: 1,
    }

    const { tony } = await deploy()
    await tony.contract.new_game()
    const state = parse_struct(await tony.contract.s_game(tony.address))
    expect(state).to.deep.equalInAnyOrder(expected_state)
  })

  it('should set the total waves uint', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    expect(await tony.contract.i_total_waves()).to.equal(1)
  })

  it(`should load the wave's mob into the game state`, async () => {
    const { tony } = await deploy()

    await tony.contract.new_game()
    const mobs = [...(await tony.contract.get_mobs())].map(parse_struct)
    expect(mobs[0]).to.deep.equalInAnyOrder({
      spawned: false,
      reached_goal: false,
      cell_id: 0,
      steps: 0,
      target_cell_index: 1,
      life: 10,
      damage: 0,
      speed: 20,
      delay: 0,
    })
  })
}
