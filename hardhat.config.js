import '@nomicfoundation/hardhat-toolbox'
import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-etherscan'
import dotenv from 'dotenv'

dotenv.config()

const {
  CMC_KEY,
  MUMBAI_RPC,
  ETH_PRIVATE_KEY,
  ETHERSCAN_APIKEY,
  POLYGONSCAN_API_KEY,
} = process.env

const settings = {
  optimizer: {
    enabled: true,
  },
}

export default {
  solidity: {
    version: '0.8.16',
    settings,
  },
  gasReporter: {
    enabled: true,
    token: 'MATIC',
    currency: 'EUR',
    showTimeSpent: true,
    ...(CMC_KEY && { coinmarketcap: CMC_KEY }),
  },
  networks: {
    mumbai: {
      url: MUMBAI_RPC,
      accounts: [ETH_PRIVATE_KEY],
    },
  },
  namedAccounts: {
    owner: {
      default: 0,
    },
  },
  etherscan: {
    apiKey: {
      goerli: ETHERSCAN_APIKEY,
      polygon: POLYGONSCAN_API_KEY,
      polygonMumbai: POLYGONSCAN_API_KEY,
    },
  },
}
