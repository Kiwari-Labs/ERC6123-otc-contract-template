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
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/** @title Standard Trade Validator
 * @notice This contract serves as a example for creating condition for agreements,
 * It facilitates programmable agreements between two parties involving the exchange or validation of token amounts.
 * @author Kiwari Labs
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AddressComparators} from "../libraries/comparators/AddressComparators.sol";
import {BlockNumberComparators} from "../libraries/comparators/BlockNumberComparators.sol";
import {UIntComparators} from "../libraries/comparators/UIntComparators.sol";
import {IERC6123OTC} from "../interfaces/ERC6123/extensions/IERC6123OTC.sol";
import {AbstractTradeValidator} from "../AbstractTradeValidator.sol";

contract StandardTradeValidator is AbstractTradeValidator {
    using AddressComparators for address;
    using BlockNumberComparators for uint256;
    using UIntComparators for uint256;

    constructor(
        string memory tradeDataABI,
        string memory settlementDataABI,
        string memory terminationTermsABI
    ) AbstractTradeValidator(tradeDataABI, settlementDataABI, terminationTermsABI) {}

    /**
     * @return bool
     */
    function _checkAllowance(address token, address owner, address OTCContract, uint256 requiredAmountToken) private view returns (bool) {
        return
            IERC20(token).balanceOf(owner).greaterThanOrEqualTo(requiredAmountToken) &&
            IERC20(token).allowance(owner, OTCContract).greaterThanOrEqualTo(requiredAmountToken);
    }

    /**
     * @return bool
     */
    function _validateTradeData(bytes memory tradeData) internal view override returns (bool) {
        // decode amounts and addresses from both parties
        (uint256 partyAGetTokenB, uint256 partyBGetTokenA, address OTCContract) = abi.decode(tradeData, (uint, uint, address));

        // variable
        address partyA = IERC6123OTC(OTCContract).partyA();
        address partyB = IERC6123OTC(OTCContract).partyB();
        address tokenA = IERC6123OTC(OTCContract).tokenA();
        address tokenB = IERC6123OTC(OTCContract).tokenB();

        // condition
        require(_checkAllowance(tokenA, partyA, OTCContract, partyBGetTokenA), "");
        require(_checkAllowance(tokenB, partyB, OTCContract, partyAGetTokenB), "");

        return true;
    }

    /**
     * @return bool
     */
    function _validateSettlementData(bytes memory settlementData) internal view override returns (bool) {
        // @TODO
        // require(block.number.before(deadline));

        return true;
    }

    /**
     * @return bool
     */
    function _validateTerminationTerms(bytes memory terminationTerms) internal view override returns (bool) {
        // @TODO
        // require(block.number.before(deadline));

        return true;
    }

    /**
     * @return uint256
     * @return uint256
     */
    function getValue(bytes memory settlementData) external view returns (uint256, uint256) {
        (uint256 a, uint256 b) = abi.decode(settlementData, (uint, uint));

        return (a, b);
    }
}
```

## Events and Histories

This implementation doesn't store the full history on-chain. However, you can retrieve past events efficiently using filters. Use `DEPLOYED_BLOCKNUMBER` to get the starting block, and `LASTSEEN_BLOCKNUMBER` for the latest block the contract interacted with.

## Contribute

Contribute guideline. See the [CONTRIBUTE](CONTRIBUTE) guide.

### Support and Issue

For support or any inquiries, feel free to reach out to us at [github-issue](https://github.com/Kiwari-Labs/bilateral-agreement-contract-template/issues) or kiwarilabs@protonmail.com

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
