import deep_equal from 'deep-equal-in-any-order'
import chai, { expect } from 'chai'
import { deployments, ethers } from 'hardhat'

chai.use(deep_equal)

const parse_struct = fields =>
  Object.fromEntries(
    Object.entries(fields)
      .filter(([key]) => isNaN(key))
      .map(([key, value]) => {
        if (value._isBigNumber) return [key, value.toNumber()]
        return [key, value]
      })
  )

const deploy = async () => {
  await deployments.fixture()
  const [bruce, tony] = await ethers.getSigners()
  return {
    bruce: {
      contract: await ethers.getContract('PaperDefense', bruce),
      address: await bruce.getAddress(),
    },
    tony: {
      contract: await ethers.getContract('PaperDefense', tony),
      address: await tony.getAddress(),
    },
  }
}

describe('Starting a new Game', function () {
  it(`should set a specific state to the player's game`, async () => {
    const expected_state = {
      wave: 1,
      life: 0,
      wave_started: false,
      finished: false,
      tick: 0,
      mob_length: 1,
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
      target_cell_index: 0,
      life: 3,
      damage: 0,
      speed: 1,
      delay: 0,
    })
  })
})
