// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

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

    function requestTradeTermination(string memory tradeId, int256 terminationPayment, string memory terminationTerms) external;

    function cancelTradeTermination(string memory tradeId, int256 terminationPayment, string memory terminationTerms) external;

    function confirmTradeTermination(string memory tradeId, int256 terminationPayment, string memory terminationTerms) external;

    function initiateSettlement() external;

    function performSettlement(int256 settlementAmount, string memory settlementData) external;

    function afterTransfer(bool success, uint256 transactionID, string memory transactionData) external;

    event TradeIncepted(address indexed initiator, string tradeId, string tradeData);
    event TradeConfirmed(address indexed confirmer, string tradeId);
    event TradeCanceled(address indexed initiator, string tradeId);
    event TradeActivated(string tradeId);

    event TradeTerminationRequest(address indexed initiator, string tradeId, int256 terminationPayment, string terminationTerms);
    event TradeTerminationConfirmed(address indexed confirmer, string tradeId, int256 terminationPayment, string terminationTerms);
    event TradeTerminationCanceled(address indexed initiator, string tradeId, string terminationTerms);
    event TradeTerminated(string cause);

    event SettlementRequested(address indexed initiator, string tradeData, string lastSettlementData);
    event SettlementDetermined(address indexed initiator, int256 settlementAmount, string settlementData);
    event SettlementTransferred(string transactionData);
    event SettlementFailed(string transactionData);
}
