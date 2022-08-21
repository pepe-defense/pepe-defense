import { expect } from 'chai'
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers'
import { deployments, ethers, getNamedAccounts } from 'hardhat'
import { base64 } from 'ethers/lib/utils'

const IMAGE_URI = '<image>'
const BADGE_TYPE = '<badge_type>'

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

describe('Badges', function () {
  it('Minting should increment badges ids', async () => {
    const { john, bruce } = await deploy()
    // the minted badge id will be reflected as `tokenId`
    // in the transfer event from the ERC721 specification
    // we have to wait for that event to fire to retrieve it
    await john.contract.issue(bruce.address, IMAGE_URI, BADGE_TYPE)
    await john.contract.issue(bruce.address, IMAGE_URI, BADGE_TYPE)
    const mint_transaction = await john.contract.issue(
      bruce.address,
      IMAGE_URI,
      BADGE_TYPE
    )
    const { tokenId: badge_id } = await transfer_event(mint_transaction)
    await expect(badge_id).to.equal(2)
  })

  it('Badges should be soul bound', async () => {
    const { john, bruce } = await deploy()

    await bruce.contract.issue(john.address, IMAGE_URI, BADGE_TYPE)
    await bruce.contract.issue(john.address, IMAGE_URI, BADGE_TYPE)
    await bruce.contract.issue(john.address, IMAGE_URI, BADGE_TYPE)

    const transfers = [
      john.contract['transferFrom(address,address,uint256)'](
        john.address,
        bruce.address,
        0
      ),
      john.contract['safeTransferFrom(address,address,uint256)'](
        john.address,
        bruce.address,
        0
      ),
      john.contract['safeTransferFrom(address,address,uint256,bytes)'](
        john.address,
        bruce.address,
        0,
        0x00
      ),
    ]

    await Promise.all(
      transfers.map(transfer =>
        expect(transfer).to.be.revertedWithCustomError(
          john.contract,
          'transfer_not_allowed'
        )
      )
    )
  })

  it('The badge URI contains all required informations', async () => {
    const { john, bruce } = await deploy()
    await bruce.contract.issue(john.address, IMAGE_URI, BADGE_TYPE)

    const datas = JSON.stringify({
      name: BADGE_TYPE,
      description: 'We rocks!',
      attributes: '',
      issuer: bruce.address.toLowerCase(),
      image: IMAGE_URI,
    })
    const uri = await john.contract.tokenURI(0)
    const [header, raw_body] = uri.split(',')

    expect(header).to.equal('data:application/json;base64')
    expect(Buffer.from(raw_body, 'base64').toString()).to.equal(datas)
  })

  it('Issuing a badge to yourself is not permitted', async () => {
    const { john } = await deploy()
    await expect(
      john.contract.issue(john.address, IMAGE_URI, BADGE_TYPE)
    ).to.be.revertedWith('Issuing a badge to yourself is not allowed')
  })
})
