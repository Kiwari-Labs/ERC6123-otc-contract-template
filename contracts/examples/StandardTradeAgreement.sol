// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/** @title Standard Trade Agreement
 * @notice This contract serves as a example for creating bilateral agreements based on token amounts.
 * It facilitates programmable agreements between two parties involving the exchange or validation of token amounts.
 * @author Kiwari Labs
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AddressComparators} from "../libraries/comparators/AddressComparators.sol";
import {UIntComparators} from "../libraries/comparators/UIntComparators.sol";
import {AbstractTradeValidator} from "../AbstractTradeValidator.sol";

contract StandardTradeAgreement is AbstractTradeValidator {
    using AddressComparators for address;
    using UIntComparators for uint256;

    constructor(
        string memory tradeDataABI,
        string memory settlementDataABI,
        string memory terminationTermsABI
    )
        AbstractTradeValidator(
            tradeDataABI,
            settlementDataABI,
            terminationTermsABI
        )
    {}

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
    ) private view returns (bool) {
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

    function _validateTradeData(
        bytes memory tradeData
    ) internal view override returns (bool) {
        // decode amounts and addresses from both parties
        (
            uint amountTokenA,
            uint requiredAmountTokenB,
            address tokenA,
            address agreementContractA,
            uint amountTokenB,
            uint requiredAmountTokenA,
            address tokenB,
            address agreementContractB
        ) = abi.decode(
                tradeData,
                (uint, uint, address, address, uint, uint, address, address)
            );
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
        // require(
            // @TODO missing parameters
            // _verifyBalanceToken(amountTokenA, agreementContractA) &&
            //     _verifyBalanceToken(amountTokenB, agreementContractB),
            // "Invalid token balances"
        // );
        
        return true;
    }

    function _validateSettlementData(bytes memory settlementData) internal override view returns (bool) {
        // @TODO
        // require(block.number.before(deadline));
        
        return true;
    }

    function _validateTerminationTerms(bytes memory terminationTerms) internal override view returns (bool) {
        // @TODO
        // require(block.number.before(deadline));
        
        return true;
    }

    /** */
    function getValue(bytes memory settlementData) external view returns (uint256, uint256) {
        return (0, 0);
    }
}
