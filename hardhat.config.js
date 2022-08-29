import '@nomicfoundation/hardhat-toolbox'
import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-etherscan'
import dotenv from 'dotenv'

dotenv.config()

// 0x6154f0Edd49C38C434d98175C1DECe68047F4952
const TEST_ETH_PRIVATE_KEY =
  '038bd6788c61c62b46c61a669462b653ceff07297d55ff58b0ef8fa30488055c'

const { CMC_KEY } = process.env

const settings = {
  optimizer: {
    enabled: true,
    // runs: 20,
  },
}

export default {
  solidity: {
    compilers: [
      { version: '0.8.16', settings },
      { version: '^0.8.0', settings },
    ],
  },
  gasReporter: {
    enabled: true,
    // token: 'MATIC',
    currency: 'EUR',
    showTimeSpent: true,
    ...(CMC_KEY && { coinmarketcap: CMC_KEY }),
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
