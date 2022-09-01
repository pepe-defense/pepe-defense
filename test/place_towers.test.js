import { expect } from 'chai'

import parse_struct from './util/parse_struct.js'

export default deploy => () => {
  it('should make sure the game is started before', async () => {
    const { tony } = await deploy()
    await expect(
      tony.contract.place_towers([5], 1, 1, 1)
    ).to.be.revertedWithCustomError(tony.contract, 'game_not_started')
  })

  it('prevent placing a tower if the game is lost', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()
    await tony.contract.start_wave()
    await expect(
      tony.contract.place_towers([5], 1, 1, 1)
    ).to.be.revertedWithCustomError(tony.contract, 'game_lost')
  })

  it(`prevent placing a tower on the ennemies path`, async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await expect(
      tony.contract.place_towers([0, 3], 1, 1, 1)
    ).to.be.revertedWithCustomError(tony.contract, 'forbidden_terrain')
  })

  it('should place towers on corrects cells', async () => {
    const tower = {
      damage: 3,
      range: 2,
      fire_rate: 4,
      last_fired: 0,
    }
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.place_towers(
      [12, 22],
      tower.damage,
      tower.range,
      tower.fire_rate
    )

    const [cells, towers] = await tony.contract.get_towers()

    expect(cells).to.deep.equal([12, 22])
    expect(towers.map(parse_struct)).to.deep.equalInAnyOrder([tower, tower])
  })
}
