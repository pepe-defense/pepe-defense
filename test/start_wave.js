import { expect } from 'chai'

import extract_event from './extract_event.js'

export default deploy => () => {
  it('should revert if the the wave is already started', async () => {
    const { tony } = await deploy()

    await tony.contract.new_game()

    const [error] = [
      ...(await Promise.allSettled([
        tony.contract.start_wave(),
        tony.contract.start_wave(),
      ])),
    ].filter(({ status }) => status === 'rejected')
    expect(error.reason.toString()).to.be.equal(
      "Error: VM Exception while processing transaction: reverted with reason string 'You did not complete the previous wave'"
    )
  })
  it('should loose the game if there is no towers', async () => {
    const { tony } = await deploy()
    const expected = {
      player: tony.address,
      wave: 1,
      won: false,
    }

    await tony.contract.new_game()
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
    await tony.contract.place_towers([12])

    const result = await tony.contract.start_wave().then(extract_event)
    expect(result).to.deep.equalInAnyOrder(expected)
  })
}
