import { expect } from 'chai'
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers'
import { deployments, ethers, getNamedAccounts } from 'hardhat'
import { base64 } from 'ethers/lib/utils'

const deploy = async () => {
  await deployments.fixture()
  const [bruce, john] = await ethers.getSigners()
  const contract = await ethers.getContract('Badges', bruce)
  return {
    bruce: {
      contract: await ethers.getContract('Badges', bruce),
      address: await bruce.getAddress(),
    },
    john: {
      contract: await ethers.getContract('Badges', john),
      address: await john.getAddress(),
    },
  }
}

const transfer_event = transaction =>
  transaction
    .wait()
    .then(({ events }) => events)
    .then(([{ args }]) => args)

describe('PaperDefense', function () {})
