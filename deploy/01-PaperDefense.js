export default async ({ getNamedAccounts, deployments: { deploy } }) => {
  const { owner } = await getNamedAccounts()
  await deploy('PaperDefense', {
    from: owner,
    log: true,
  })
}
