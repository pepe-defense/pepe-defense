import { expect } from 'chai'

import parse_struct from './parse_struct.js'

export default deploy => () => {
  it('should make sure the game is started before', async () => {
    const { tony } = await deploy()
    await expect(tony.contract.place_towers([5])).to.be.revertedWith(
      'The game must be started'
    )
  })

  it('should make sure no wave is started', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()
    await expect(tony.contract.place_towers([5])).to.be.revertedWith(
      "Towers can't be placed after a wave is launched"
    )
  })

  it(`prevent placing a tower on the ennemies path`, async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await expect(tony.contract.place_towers([0, 3])).to.be.revertedWith(
      "You can't place a tower on the ennemies path"
    )
  })

  it('should place towers on corrects cells', async () => {
    const tower = {
      damage: 5,
      range: 2,
      fire_rate: 3,
      last_fired: 0,
    }
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.place_towers([12, 22])
    const towers = [...(await tony.contract.get_towers())].map(parse_struct)

    expect(towers).to.deep.equalInAnyOrder([tower, tower])
  })
}
