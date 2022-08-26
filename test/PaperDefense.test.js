import deep_equal from 'deep-equal-in-any-order'
import chai from 'chai'
import { deployments, ethers } from 'hardhat'

import new_game from './new_game.js'
import place_towers from './place_towers.js'
import start_wave from './start_wave.js'

chai.use(deep_equal)

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

describe('Starting a new Game', new_game(deploy))
describe('Placing towers', place_towers(deploy))
describe('Starting waves', start_wave(deploy))
