import deep_equal from 'deep-equal-in-any-order'
import chai from 'chai'
import { deployments, ethers } from 'hardhat'

import new_game from './new_game.test.js'
import place_towers from './place_towers.test.js'
import start_wave from './start_wave.test.js'
import print_wave from './util/print_waves.js'
import leaderboard from './leaderboard.test.js'

chai.use(deep_equal)

print_wave(20)

const deploy = async () => {
  await deployments.fixture()
  const [bruce, tony] = await ethers.getSigners()
  return {
    bruce: {
      contract: await ethers.getContract('PepeDefense', bruce),
      address: await bruce.getAddress(),
    },
    tony: {
      contract: await ethers.getContract('PepeDefense', tony),
      address: await tony.getAddress(),
    },
  }
}

describe('Starting a new Game', new_game(deploy))
describe('Placing towers', place_towers(deploy))
describe('Starting waves', start_wave(deploy))
describe('The leaderboard', leaderboard(deploy))
