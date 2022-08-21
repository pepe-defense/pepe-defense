import '@nomicfoundation/hardhat-toolbox'
import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-etherscan'
import dotenv from 'dotenv'

dotenv.config()

// 0x6e0e181fE9FECD42a55f8F1DE6f14fFEF6B0ef1d
const TEST_ETH_PRIVATE_KEY =
  '3065dd71bc8c9471cd03b0a88139d601e3cf8c315de8deb9efabec8d49f52965'

export default {
  solidity: {
    compilers: [{ version: '0.8.16' }, { version: '^0.8.0' }],
  },
  gasReporter: {
    enabled: true,
  },
  networks: {
    goerli: {
      url: process.env.GOERLI,
      accounts: [process.env.PRIVATE_KEY || TEST_ETH_PRIVATE_KEY],
    },
  },
  namedAccounts: {
    owner: {
      default: 0,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_APIKEY,
  },
}
