import { expect } from 'chai'

const number = bn => bn.toNumber()

export default deploy => () => {
  it(`should set a specific state to the player's game`, async () => {
    const expected_state = {
      wave: 1,
      life: 10,
      finished: false,
      score: 0,
      total_tick: 0,
    }

    const { tony } = await deploy()
    await tony.contract.new_game()

    expect({
      wave: await tony.contract.get_wave(),
      life: await tony.contract.get_life(),
      finished: await tony.contract.get_is_finished(),
      score: await tony.contract.get_score().then(number),
      total_tick: await tony.contract.get_total_tick().then(number),
    }).to.deep.equalInAnyOrder(expected_state)
  })
}
