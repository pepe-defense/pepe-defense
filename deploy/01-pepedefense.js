import { ethers } from 'hardhat'
import { iter } from 'iterator-helper'

const FACETS = [
  'DiamondLoupeFacet',
  'OwnershipFacet',
  'LeaderboardFacet',
  'PepeDefenseFacet',
  'StateViewFacet',
]

const CUT_ACTION = { Add: 0, Replace: 1, Remove: 2 }

const get_selectors = contract => {
  return Object.keys(contract.interface.functions)
    .filter(func => func !== 'init(bytes)')
    .map(func => contract.interface.getSighash(func))
}

const tap = trace => x => (trace(x), x)

const deploy = (name, ...params) =>
  ethers
    .getContractFactory(name)
    .then(tap(() => process.stdout.write(`║ ${name}`.padEnd(25, ' '))))
    .then(contract => contract.deploy(...params))
    .then(
      tap(({ deployTransaction: { hash } }) =>
        process.stdout.write(`${hash} | `)
      )
    )
    .then(contract => contract.deployed())
    .then(tap(({ address }) => process.stdout.write(address)))
    .then(tap(() => console.log('')))

export default async ({ getNamedAccounts }) => {
  const { owner } = await getNamedAccounts()
  console.log('\n╔══════════════════════════════════════════[ Deploying..')
  // ╔═════════════════════════════════════════════════════════════[ Diamond Cut
  const diamond_cut_facet = await deploy('DiamondCutFacet')
  // ╔═════════════════════════════════════════════════════════════[ Diamond
  const diamond = await deploy('Diamond', owner, diamond_cut_facet.address)
  // ╔═════════════════════════════════════════════════════════════[ Diamond init
  const pepe_init = await deploy('InitPepe')
  // ╔═════════════════════════════════════════════════════════════[ Facets
  const cuts = await iter(FACETS)
    .toAsyncIterator()
    .map(async facet_name => {
      const facet = await deploy(facet_name)
      return {
        facetAddress: facet.address,
        action: CUT_ACTION.Add,
        functionSelectors: get_selectors(facet),
      }
    })
    .toArray()

  console.log('╚══════════════════════════')

  // ╔═════════════════════════════════════════════════════════════[ Init call
  const diamond_cut = await ethers.getContractAt('IDiamondCut', diamond.address)

  const init_function = pepe_init.interface.encodeFunctionData('init')

  console.log('\nCutting diamond..')

  const transaction = await diamond_cut.diamondCut(
    cuts,
    pepe_init.address,
    init_function
  )

  const receipt = await transaction.wait()
  if (!receipt.status)
    throw new Error(`Diamond upgrade failed: ${transaction.hash}`)
  console.log('\nDiamond cut completed ☘️ ')
}
