// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title Customized Agreement
/// @author <author@domain.com>

import "@kiwarilabs/contracts/abstracts/AgreementTemplate.sol";

contract CustomizedAgreement is AgreementTemplate {
    function _verifyAgreement(
        bytes memory x,
        bytes memory y
    ) internal override returns (bool) {
        // #################### start your custom logic ####################
        // ... desirable logic here
        // #################### end your custom logic ####################
        // do not change the line below.
        return true;
    }
}
