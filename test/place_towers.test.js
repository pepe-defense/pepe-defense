import { expect } from 'chai'

import parse_struct from './util/parse_struct.js'

const DEFAULT_TOWER = {
  damage: 1,
  range: 1,
  fire_rate: 1,
  last_fired: 0,
  score_value: 100,
}

export default deploy => () => {
  it('should make sure the game is started before', async () => {
    const { tony } = await deploy()
    await expect(
      tony.contract.set_towers([{ ...DEFAULT_TOWER, cell_id: 5 }])
    ).to.be.revertedWith('The game must be started')
  })

  it('prevent placing a tower if the game is lost', async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.start_wave()
    await tony.contract.start_wave()
    await expect(
      tony.contract.set_towers([{ ...DEFAULT_TOWER, cell_id: 5 }])
    ).to.be.revertedWith('The game is over')
  })

  it(`prevent placing a tower on the ennemies path`, async () => {
    const { tony } = await deploy()
    await tony.contract.new_game()
    await expect(
      tony.contract.set_towers([
        { ...DEFAULT_TOWER, cell_id: 0 },
        { ...DEFAULT_TOWER, cell_id: 3 },
      ])
    ).to.be.revertedWith('Placing tower on mobs path')
  })

  it('should place towers on corrects cells', async () => {
    const tower = {
      ...DEFAULT_TOWER,
      damage: 3,
      range: 2,
      fire_rate: 4,
    }
    const { tony } = await deploy()
    await tony.contract.new_game()
    await tony.contract.set_towers([
      { ...tower, cell_id: 12 },
      { ...tower, cell_id: 22 },
    ])

    const towers = await tony.contract.get_towers()

    expect(towers.map(parse_struct)).to.deep.equalInAnyOrder([
      { ...tower, cell_id: 12 },
      { ...tower, cell_id: 22 },
    ])
  })
}
