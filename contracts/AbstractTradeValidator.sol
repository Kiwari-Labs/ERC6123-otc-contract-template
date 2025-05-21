// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {ITradeValidator} from "./interfaces/ITradeValidator.sol";

/**
 * @title Abstract Trade Validator
 * @author Kiwari Labs
 */

abstract contract AbstractTradeValidator is ITradeValidator {
    string private TRADE_DATA_ABI_ENCODE;
    string private SETTLEMENT_DATA_ABI_ENCODE;
    string private TERMINATION_TERMS_ABI_ENCODE;

    // @TODO division identifier?
    // string private AUTHOR;
    // string private AUDITOR;
    // string private URI_CONTRACT_PAPER;
    // string private URI_AUDIT_REPORT;

    constructor(
        string memory tradeDataABI,
        string memory settlementDataABI,
        string memory terminationTermsABI
    ) {
        TRADE_DATA_ABI_ENCODE = tradeDataABI;
        SETTLEMENT_DATA_ABI_ENCODE = settlementDataABI;
        TERMINATION_TERMS_ABI_ENCODE = terminationTermsABI;
    }

    /**
     * @dev See {ITradeValidator-validateTradeData}.
     */
    function validateTradeData(
        bytes memory tradeData
    ) external view override returns (bool) {
        require(_validateTradeData(tradeData));
        return true;
    }

    /**
     * @dev See {ITradeValidator-validateSettlementData}.
     */
    function validateSettlementData(
        bytes memory settlementData
    ) external view override returns (bool) {
        require(_validateSettlementData(settlementData));
        return true;
    }

    /**
     * @dev See {ITradeValidator-validateTerminationTerms}.
     */
    function validateTerminationTerms(
        bytes memory terminationTerms
    ) external view override returns (bool) {
        require(_validateTerminationTerms(terminationTerms));
        return true;
    }

    /**
     * @dev See {ITradeValidator-tradeDataABI}.
     */
    function tradeDataABI() external view override returns (string memory) {
        return TRADE_DATA_ABI_ENCODE;
    }

    /**
     * @dev See {ITradeValidator-settlementDataABI}.
     */
    function settlementDataABI()
        external
        view
        override
        returns (string memory)
    {
        return SETTLEMENT_DATA_ABI_ENCODE;
    }

    /**
     * @dev See {ITradeValidator-terminationTermsABI}.
     */
    function terminationTermsABI()
        external
        view
        override
        returns (string memory)
    {
        return TERMINATION_TERMS_ABI_ENCODE;
    }

    /**
     * @dev abstract function
     */
    function _validateTradeData(
        bytes memory tradeData
    ) internal view virtual returns (bool) {
        // validation logic here.
    }

    /**
     * @dev abstract function
     */
    function _validateSettlementData(
        bytes memory settlementData
    ) internal view virtual returns (bool) {
        // validation logic here.
    }

    /**
     * @dev abstract function
     */
    function _validateTerminationTerms(
        bytes memory terminationTerms
    ) internal view virtual returns (bool) {
        // validation logic here.
    }
}
