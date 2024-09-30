// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title General Token Amount Agreement
/// @notice This contract serves as a template for creating bilateral agreements based on token amounts.
/// It facilitates programmable agreements between two parties involving the exchange or validation of token amounts.
/// @author Kiwari Labs

import "@kiwarilabs/contracts/libraries/utils/AddresComparator.sol";
import "@kiwarilabs/contracts/libraries/utils/IntComparator.sol";
import "@kiwarilabs/contracts/abstract/AgreementTemplate.sol";

contract GeneralTokenAgreement is AgreementTemplate {
    using IntComparator for uint256;
    using AddressCompartor for address;

    function _verifyAmountToken(
        uint inputTokenAmount,
        uint requiredAmount
    ) private pure returns (bool) {
        return inputTokenAmount.equal(requiredAmount);
    }

    function _verifyBalanceToken(
        address token,
        address bilateralAgreementContract,
        uint requiredAmountToken
    ) private pure returns (bool) {
        return
            (IERC20(token).balanceOf(bilateralAgreementContract)).equal(
                requiredAmountToken
            );
    }

    function _verifyBilateralContract(
        address contractA,
        address contractB
    ) private pure returns (bool) {
        return contractA.equal(contractB);
    }

    function _verifyAgreement(
        bytes memory x,
        bytes memory y
    ) internal override returns (bool) {
        // #################### start your custom logic ####################
        // Decode amounts and addresses from both parties
        (
            uint amountTokenA,
            uint requiredAmountTokenB,
            address tokenA,
            address agreementContractA
        ) = abi.decode(x, (uint, uint, address, address));
        (
            uint amountTokenB,
            uint requiredAmountTokenA,
            address tokenB,
            address agreementContractB
        ) = abi.decode(y, (uint, uint, address, address));
        // Verify contract addresses, token amounts, and balances
        require(
            _verifyBilateralContract(agreementContractA, agreementContractB),
            "Invalid agreement contract"
        );
        require(
            _verifyAmountToken(amountTokenA, requiredAmountTokenA) &&
                _verifyAmountToken(amountTokenB, requiredAmountTokenB),
            "Invalid token amounts"
        );
        require(
            _verifyBalanceToken(amountTokenA, agreementContractA) &&
                _verifyBalanceToken(amountTokenB, agreementContractB),
            "Invalid token balances"
        );
        // #################### end your custom logic ####################
        // do not change the line below.
        return true;
    }
}
