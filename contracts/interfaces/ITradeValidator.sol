// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Interface Trade Validator
 * @author Kiwari Labs
 */

interface ITradeValidator {
    /**
     * @param tradeData payload
     */
    function validateTradeData(bytes memory tradeData) external view returns (bool);

    /**
     * @param settlementData payload
     */
    function validateSettlementData(bytes memory settlementData) external view returns (bool);

    /**
     * @param terminationTerms payload
     */
    function validateTerminationTerms(bytes memory terminationTerms) external view returns (bool);
}