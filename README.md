# bilateral-agreement-contract-template

## Overview

The `bilateral-agreement-contract-template` represents a foundational framework for adopting bilateral agreement mechanisms in distributed environments. It bridges traditional contract law and its principles with programmable, self-executing agreements, commonly referred to as smart contracts. This template can serve as a guideline for constructing agreements between two parties, akin to traditional bilateral contracts, but fully integrated into DLT-based Loyalty Platform.

## Diagram

<!-- TODO png or mermaid -->

## Clone repository to development environment

``` shell
git clone http://github.com/Kiwari-labs/bilateral-agreeement-template.git
```

## Installing

To install all necessary packages and dependencies in the project, run the command

```
yarn install
```

## Compile the code

To compile the smart contracts, run the command

```
yarn compile
```

## Testing

To run the tests and ensure that the contracts behave as expected, run the command

```
yarn test
```

## Example build you first custom agreement

<!-- Instruction / Walkthrough -->

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title Agreement Title
/// @notice e.g. link to Term of Usage, Policies, Code of Conduct
/// @dev describe or URL external link
/// @custom:first_author @first_author <first_author@domain.com>
/// @custom:second_author @second_author <second_author@domain.com>

import "@kiwiarilabs/contracts/libraries/utils/AddressComparator.sol";
import "@kiwiarilabs/contracts/libraries/utils/IntComparator.sol";
import "@kiwairilabs/contracts/abstracts/AgreementTemplate.sol";

// MUST `import ../template/AgreementTemplate.sol`, DO NOT delete `is AgreementTemplate`.
contract AgreementLogic is AgreementTemplate {

    // solc-ignore-next-line func-mutability
    function _verifyAgreement(
        bytes memory x,
        bytes memory y
    ) internal override returns (bool) {
        // #################### start your custom logic ####################
        // decoding data from bytes to first is the address of token second is the amount of token,
        // other for whatever additional data.
        // abi.decode(x, (address, uint256, others);
        // abi.decode(y, (address, uint256, others));
        // require(_condition(x, y),"error message");
        // ... more condition if needed
        // #################### end your custom logic ####################
        // do not change the line below.
        return true;
    }
}
```

## Contribute

Contribute guideline. See the [CONTRIBUTE](CONTRIBUTE) guide.

### Support and Issue

For support or any inquiries, feel free to reach out to us at [github-issue](https://github.com/Kiwari-Labs/bilateral-agreement-contract-template/issues) or kiwarilabs@protonmail.com

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
