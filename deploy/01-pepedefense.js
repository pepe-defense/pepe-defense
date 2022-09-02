export default async ({ getNamedAccounts, deployments: { diamond } }) => {
  const { owner } = await getNamedAccounts()
  await diamond.deploy('PepeDefense', {
    from: owner,
    owner,
    facets: ['LeaderboardFacet', 'PepeDefenseFacet', 'StateViewFacet'],
    log: true,
    execute: {
      contract: 'PepeUpgrade',
      methodName: 'post_upgrade',
      args: [],
    },
  })
}
