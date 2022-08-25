import { expect } from 'chai'
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers'
import { deployments, ethers, getNamedAccounts } from 'hardhat'
import { base64 } from 'ethers/lib/utils'

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
  const [bruce, john] = await ethers.getSigners()
  const contract = await ethers.getContract('PaperDefense', bruce)
  return {
    bruce: {
      contract: await ethers.getContract('PaperDefense', bruce),
      address: await bruce.getAddress(),
    },
    tony: {
      contract: await ethers.getContract('PaperDefense', john),
      address: await john.getAddress(),
    },
  }
}

describe('Starting a new Game', function () {
  it(`should load the wave's mob into the game state`, async () => {
    const { tony } = await deploy()

    await tony.contract.new_game()
    const mobs = [...(await tony.contract.get_mobs())].map(parse_struct)
    expect(mobs[0]).to.deep.equal({
      cell_id: 0,
      damage: 0,
      delay: 0,
      life: 3,
      reached_goal: false,
      spawned: false,
      speed: 1,
      steps: 0,
      target_cell_index: 0,
    })
  })
})
