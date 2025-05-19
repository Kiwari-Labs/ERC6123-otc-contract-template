// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {ITradeValidator} from "./interfaces/ITradeValidator.sol";

/**
 * @title Abstract Trade Validator
 * @author Kiwari Labs
 */

abstract contract AbstractTradeValidator is ITradeValidator {
    /**
     * @dev See {ITradeValidator-validateTradeData}.
     */
    function validateTradeData(bytes memory tradeData) external override view returns (bool) {
        require(_validateTradeData(tradeData));
        return true;
    }
    
    /**
     * @dev See {ITradeValidator-validateSettlementData}.
     */
    function validateSettlementData(bytes memory settlementData) external override view returns (bool) {
        require(_validateSettlementData(settlementData));
        return true;
    }

    /**
     * @dev See {ITradeValidator-validateTerminationTerms}.
     */
    function validateTerminationTerms(bytes memory terminationTerms) external override view returns (bool) {
        require(  _validateTerminationTerms(terminationTerms));
        return true;
    }

    /**
     * @dev abstract function
     */
    function _validateTradeData(bytes memory tradeData) internal virtual view returns (bool) {
        // validation logic here.
    }

    /**
     * @dev abstract function
     */
    function _validateSettlementData(bytes memory settlementData)internal virtual view returns (bool) {
        // validation logic here.
    }

    /**
     * @dev abstract function
     */
    function _validateTerminationTerms(bytes memory terminationTerms) internal virtual view returns (bool) {
        // validation logic here.
    }
}