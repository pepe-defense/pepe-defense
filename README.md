# affinidi-badges-smart-contract

> The current repo depends on the `esm` package because Hardhat doesn't support it.
> They seems [to have it planned](https://github.com/NomicFoundation/hardhat/issues/957) but it's not there yet.
> This means you can't run `npx hardhat` to interract with this repo

## Install

```sh
git clone git@gitlab.com:affinidi/internal-tools/affinidi-badges-smart-contract.git
cd affinidi-badges-smart-contract
```

```sh
npm i
```

## Usage

Deploy the contract on the desired chain

```sh
npm run deploy # deploying on localhost (hardhat VM)

npm run hardhat -- --network goerli deploy
npm run hardhat -- --network <network> deploy # deploying to one of the configured network
```

### Networks configuration

In the `hardhat.config.js`

```json
{
  networks: {
    ropsten: {
      url: "<rpc url>",
      accounts: [privateKey]
    }
  }
}
```

## Compile Manually

You can compile the contract by running

```sh
npm run compile
```

## Test & Coverage

Test are provided by `chai` whith matchers included in Hardhat, the coverage is also included.

```sh
npm test # coverage 100
```

You can also run the test with a summary of Gas used

```sh
npm run gasreport
```

## Prettier & Lint

```sh
npm run Format # format the code
npm run lint # check with solhint
```

## Verification

Verify the contract on etherscan

```sh
npm run hardhat -- --verify
```
