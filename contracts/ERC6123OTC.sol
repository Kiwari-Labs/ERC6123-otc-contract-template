// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

import {String} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC6123} from "./interfaces/IERC6123.sol";

/**
 * @title ERC6123 Over-The-Counter (OTC)
 * @author Kiwari Labs
 */

abstract contract ERC6123OTC is IERC6123 {
    using String for uint256;

    enum DATA_FORMAT {
        BYTES,
        JSON,
        XML
    }

    enum TRADE_STATE {
        INACTIVE,
        INCEPTED,
        CONFIRMED,
        VALUATION,
        IN_TRANSFER,
        SETTLED,
        IN_TERMINATED,
        TERMINATED
    }

    address private _partyA;
    address private _partyB;

    IERC20 private _tokenA;
    IERC20 private _tokenB;

    TRADE_STATE private _tradeState;

    string private _tradeId;
    string private _tradeData;
    string private _terminationTerms;

    modifier whenTradeInactive() {
        if (_tradeState != TRADE_STATE.INACTIVE) {
            revert ();
        }
        _;
    }

    modifier whenTradeIncepted() {
        if (_tradeState != TRADE_STATE.INCEPTED) {
            revert ();
        }
        _;
    }
    
    modifier whenConfirmed() {
        if (_tradeState != TRADE_STATE.CONFIRMED) {
            revert ();
        }
        _;
    }

    modifier whenValuation() {
        if (_tradeState != TRADE_STATE.VALUATION) {
            revert ();
        }
        _;
    }

    modifier whenInTransfer() {
        if (_tradeState != TRADE_STATE.IN_TRANSFER) {
            revert ();
        }
        _;
    }

    modifier whenSettled() {
        if (_tradeState != TRADE_STATE.SETTLED) {
            revert ();
        }
        _;
    }

    modifier whenInTerminated() {
        if (_tradeState != TRADE_STATE.IN_TERMINATED) {
            revert ();
        }
        _;
    }

    // function _generateTradeId() internal returns (bytes32) {
    //  return ;
    // }

    function _updateTradeState(TRADE_STATE state) internal {
        TRADE_STATE tradeState = _tradeState;
        if (state == TRADE_STATE.INCEPTED && tradeState != TRADE_STATE.INACTIVE) {
            revert ();
        }
        if (state == TRADE_STATE.CONFIRMED && tradeState != TRADE_STATE.INCEPTED) {
            revert ();
        }
        if (state == TRADE_STATE.IN_TRANSFER && !(tradeState == TRADE_STATE.CONFIRMED || tradeState == TRADE_STATE.VALUATION)) {
            revert ();
        }
        if (state == TRADE_STATE.VALUATION && tradeState != TRADE_STATE.SETTLED) {
            revert ();
        }
        if (state == TRADE_STATE.IN_TERMINATED && !(tradeState == TRADE_STATE.IN_TRANSFER || tradeState == TRADE_STATE.SETTLED )) {
            revert ();
        }
        state = tradeState;
    }

    function inceptTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external virtual override returns (string memory) {
        address initiator = msg.sender;
        if (initiator == withParty) {
            revert ();
        }
        if (position < -1 || position > 1) {
            revert ();
        }
        string tradeId = uint256(
            keccak256(
                abi.encode(
                    initiator,
                    withParty,
                    tradeData,
                    position,
                    paymentAmount,
                    initialSettlementData
                )
            )
        ).toHexString();
        _updateTradeState(TRADE_STATE.INCEPTED);
        // pendingRequests[tradeId] = initiator; // unclear
        // receivingParty = position == 1 ? initiator : withParty; // unclear

        emit TradeIncepted(initiator, tradeId, tradeData);
    }

    function confirmTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external virtual override {
        address confrimer = msg.sender;
        // this function should call conditional check for feasibility in data format.
        // bytes memory parsedTradeData = tradeData.parseBytes();
        // bytes memory parsedInitialSettlementData = initialSettlementData.parseBytes();
        // (type var) = abi.decode(settlementData, (types));
        // string tradeId = implementation.getTradeId(parsedInitialSettlementData);

        _updateTradeState(TRADE_STATE.CONFIRMED);
        emit TradeConfirmed(confrimer, tradeId);

        // if tradeData match
        // emit TradeActivate(tradeId);

        // otherwise
        // emit TradeTerminated("reason");
    }

    function cancelTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external virtual override {
        address initiator = msg.sender;

        emit TradeCanceled(initiator, tradeId);
    }

    function requestTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external virtual override {
        address initiator = msg.sender;

        _updateTradeState(TRADE_STATE.IN_TERMINATED);

        emit TradeTerminationRequest(
            initiator,
            tradeId,
            terminationPayment,
            terminationTerms
        );
    }

    function confirmTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external virtual override {
        address confirmer = msg.sender;

        emit TradeTerminationConfirmed(
            confirmer,
            tradeId,
            terminationPayment,
            terminationTerms
        );

        // if both side confirm
        // _updateTradeState(TRADE_STATE.TERMINATED);
        // emit TradeTermination("reason");
    }

    function cancelTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external virtual override {
        address initiator = msg.sender;

        // if counter party cancel.
        // _updateTradeState(TRADE_STATE); back to previous state or back to incept?

        emit TradeTerminationCanceled(initiator, tradeId, terminationTerms);
    }

    function initiateSettlement() external virtual {

        emit SettlementRequested(address initiator, string tradeData, string lastSettlementData);
    }

    function performSettlement(
        int256 settlementAmount,
        string memory settlementData
    ) external virtual {
        // emit SettlementDetermined(initiator, settlementAmount, settlementData);
        // afterTransfer();
    }

    function afterTransfer(bool success, uint256 transactionId, string memory transactionData) external {
        // if success 
        // emit SettlementTransferred(tradeId, transactionData);
        // otherwise fail
        // emit SettlementFailed(tradeId, transactionData);
        // emit TradeTerminated("reason");
    }

    function tradeId() public view returns (string memory) {
        return _tradeId;
    }

    function tradeState() public view return (TRADE_STATE) {
        return _tradeState;
    }

    function public view returns (address) {
        return address(_tokenA);
    }

    function public view returns (address) {
        return
    }

    function dataFormat() public pure virtual returns (DATA_FORMAT) {
        return DATA_FORMAT.BYTES;
    }

}
