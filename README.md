# bilateral-agreement-contract-template

## Overview  

The `bilateral-agreement-contract-template` represents a foundational framework for adopting bilateral agreement mechanisms in distributed environments. It bridges traditional contract law and its principles with programmable, self-executing agreements, commonly referred to as smart contracts. This template can serve as a guideline for constructing agreements between two parties, akin to traditional bilateral contracts, but fully integrated into DLT-based Loyalty Platform.

## Diagram

<!-- TODO png or mermaid -->

## Clone repository to development environment

```shell
git clone http://github.com/Kiwari-labs/bilateral-agreeement-template.git
```

## Installing  
To install all necessary packages and dependencies in the project, run command
```
yarn install
```

## Compile the code
To compile the smart contracts, run command
```
yarn compile
```

## Testing
To run the tests and ensure that the contracts behave as expected, run command
```
yarn test
```

## Example build you first custom agreement

<!-- Instruction / Walkthrough -->

```Solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

/// @title Agreement Title
/// @notice e.g. link to Term of Usage, Policies, Code of Conduct
/// @dev describe or url external link
/// @custom:author_a contact_party_A <party_a_email@domain.com>
/// @custom:author_b contact_party_B <party_b_emailA@domain.com>

import "../AddressComparator.sol";
import "../IntComparator.sol";
import "../template/AgreementTemplate.sol";

// MUST `import ../template/AgreementTemplate.sol`, DO NOT delete `is AgreementTemplate`.
contract AgreementLogic is AgreementTemplate {

    function _verifyAgreement(
        bytes memory x,
        bytes memory y
    ) internal override returns (bool) {
        // #################### start your custom logic ####################
        // decoding data from bytes to what ever.
        // abi.decode(x, types);
        // abi.decode(y, types);
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
