import { expect } from 'chai'

const number = bn => bn.toNumber()

export default deploy => () => {
  it(`should set a specific state to the player's game`, async () => {
    const expected_state = {
      wave: 1,
      life: 20,
      finished: false,
      tick: 0,
      score: 0,
    }

    const { tony } = await deploy()
    await tony.contract.new_game()

    expect({
      wave: await tony.contract.get_wave(),
      life: await tony.contract.get_life(),
      tick: await tony.contract.get_tick().then(number),
      finished: await tony.contract.get_is_finished(),
      score: await tony.contract.get_score().then(number),
    }).to.deep.equalInAnyOrder(expected_state)
  })
}
