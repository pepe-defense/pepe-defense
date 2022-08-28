export default async ({ getNamedAccounts, deployments: { deploy } }) => {
  const { owner } = await getNamedAccounts()
  await deploy('Paper_defense', {
    from: owner,
    log: true,
  })
}
