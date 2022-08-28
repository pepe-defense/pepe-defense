import { expect } from 'chai'

import parse_struct from './parse_struct.js'

export default deploy => () => {
  it(`should set a specific state to the player's game`, async () => {
    const expected_state = {
      wave: 1,
      life: 20,
      finished: false,
      tick: 0,
    }

    const { tony } = await deploy()
    await tony.contract.new_game()
    const state = parse_struct(await tony.contract.s_game(tony.address))
    expect(state).to.deep.equalInAnyOrder(expected_state)
  })
}
