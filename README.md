# ERC6123-otc-contract-template

## Overview

The `ERC6123-otc-contract-template` represents a smart contract library for adopting `over-the-counter`or `OTC` trade on blockchain. It bridges traditional contract workflow and its principles with programmable, self-executing agreements, commonly referred to as smart contracts. This template can serve as a guideline for constructing `OTC` trade of `ERC-20` between two parties.

## Sequence Diagram

<!-- TODO sequence diagram -->

## Cloning

``` shell
git clone http://github.com/Kiwari-labs/ERC6123-otc-contract-template.git
```

## Installing

To install all necessary packages and dependencies in the project, run the command

```
yarn install
```

## Compiling

To compile the smart contracts, run the command

```
yarn compile
```

## Testing

To run the tests and ensure that the contracts behave as expected, run the command

```
yarn test
```

## Guideline

## Custom Trade Validator Logic

``` solidity
// @TODO example solidity code
```

## Events and Histories

This implementation doesn't store the full history on-chain. However, you can retrieve past events efficiently using filters. Use `DEPLOYED_BLOCKNUMBER` to get the starting block, and `LASTSEEN_BLOCKNUMBER` for the latest block the contract interacted with.

## Contribute

Contribute guideline. See the [CONTRIBUTE](CONTRIBUTE) guide.

### Support and Issue

For support or any inquiries, feel free to reach out to us at [github-issue](https://github.com/Kiwari-Labs/bilateral-agreement-contract-template/issues) or kiwarilabs@protonmail.com

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
