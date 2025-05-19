// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

interface IERC6123 {
    function inceptTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external returns (string memory);

    function confirmTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external;

    function cancelTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external;

    function requestTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external;

    function cancelTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external;

    function initiateSettlement() external;

    function performSettlement(
        int256 settlementAmount,
        string memory settlementData
    ) external;

    event TradeIncepted(address initiator, string tradeId, string tradeData); // suggestion indexed initiator and tradeId
    event TradeConfirmed(address confirmer, string tradeId); // suggestion indexed confirmer and tradeId
    event TradeCanceled(address initiator, string tradeId); // suggestion indexed initiator and tradeId
    event TradeActivated(string tradeId);
    
    event TradeTerminationRequest(address initiator, string tradeId, int256 terminationPayment, string terminationTerms); // suggestion indexed initiator and tradeId
    event TradeTerminationConfirmed(address confirmer, string tradeId, int256 terminationPayment, string terminationTerms); // suggestion confirmer initiator and tradeId
    event TradeTerminationCanceled(address initiator, string tradeId, string terminationTerms); // suggestion initiator and tradeId
    event TradeTerminated(string cause);

    event SettlementRequested(address initiator, string tradeData, string lastSettlementData); // suggestion initiator
    event SettlementDetermined(address initiator, int256 settlementAmount, string settlementData); // suggestion initiator
    event SettlementTransferred(string transactionData);
    event SettlementFailed(string transactionData);
}
