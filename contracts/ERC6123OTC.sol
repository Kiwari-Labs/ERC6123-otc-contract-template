// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {StringBytes as Strings} from "./libraries/StringBytes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC6123OTC} from "./interfaces/ERC6123/extensions/IERC6123OTC.sol";
// import {TradeValidator} from "./interfaces/ITradeValidator.sol";

/**
 * @title ERC6123 Over-The-Counter (OTC)
 * @author Kiwari Labs
 */

abstract contract ERC6123OTC is IERC6123OTC {
    using Strings for string;

    enum TRADE_DATA_FORMAT {
        BYTES,
        JSON,
        XML,
        URI // can stored off-chain
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

    // ITradeValidator private _tradeValidator;

    TRADE_STATE private _tradeState;

    string private _tradeId;
    string private _tradeData;
    string private _terminationTerms;
    mapping(string => address) _pendingRequests;

    uint256 private _counter;

    error ERC6123InvalidTradeState(TRADE_STATE current, TRADE_STATE expected);

    modifier whenTradeInactive() {
        _requireState(TRADE_STATE.INACTIVE);
        _;
    }

    modifier whenTradeIncepted() {
        _requireState(TRADE_STATE.INCEPTED);
        _;
    }

    modifier whenConfirmed() {
        _requireState(TRADE_STATE.CONFIRMED);
        _;
    }

    modifier whenValuation() {
        _requireState(TRADE_STATE.VALUATION);
        _;
    }

    modifier whenInTransfer() {
        _requireState(TRADE_STATE.IN_TRANSFER);
        _;
    }

    modifier whenSettled() {
        _requireState(TRADE_STATE.SETTLED);
        _;
    }

    modifier whenInTerminated() {
        _requireState(TRADE_STATE.IN_TERMINATED);
        _;
    }

    constructor(address partyA, address partyB, IERC20 tokenA, IERC20 tokenB) {
        _partyA = partyA;
        _partyB = partyB;
        _tokenA = tokenA;
        _tokenB = tokenB;
    }

    function _requireState(TRADE_STATE expected) private {
        TRADE_STATE current = _tradeState;
        if (current != expected) {
            revert ERC6123InvalidTradeState(current, expected);
        }
    }

    function _calculateTradeId(
        address initiator,
        address withParty,
        string memory tradeData,
        int position,
        int paymentAmount,
        string memory initialSettlementData
    ) private returns (string memory) {
        return
            uint256(
                keccak256(
                    abi.encode(
                        initiator,
                        withParty,
                        tradeData,
                        position,
                        paymentAmount,
                        initialSettlementData,
                        _counter,
                        block.chainid
                    )
                )
            ).toHexString();
    }

    function _updateTradeState(TRADE_STATE state) internal {
        TRADE_STATE current = _tradeState;
        if (state == TRADE_STATE.INCEPTED && current != TRADE_STATE.INACTIVE) {
            revert ERC6123InvalidTradeState(current, TRADE_STATE.INACTIVE);
        }
        if (state == TRADE_STATE.CONFIRMED && current != TRADE_STATE.INCEPTED) {
            revert ERC6123InvalidTradeState(current, TRADE_STATE.INCEPTED);
        }
        if (
            state == TRADE_STATE.IN_TRANSFER &&
            !(current == TRADE_STATE.CONFIRMED ||
                current == TRADE_STATE.VALUATION)
        ) {
            // @TODO expected state can be confirmed or valuation.
            revert ERC6123InvalidTradeState(current, TRADE_STATE.INCEPTED);
        }
        if (state == TRADE_STATE.VALUATION && current != TRADE_STATE.SETTLED) {
            revert ERC6123InvalidTradeState(current, TRADE_STATE.SETTLED);
        }
        if (
            state == TRADE_STATE.IN_TERMINATED &&
            !(current == TRADE_STATE.IN_TRANSFER ||
                current == TRADE_STATE.SETTLED)
        ) {
            // @TODO expected state can be in transfer or settled.
            revert ERC6123InvalidTradeState(current, TRADE_STATE.INCEPTED);
        }
        _tradeState = state;
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
            revert();
        }
        if (position < -1 || position > 1) {
            revert();
        }
        string memory tradeId = _calculateTradeId(
            initiator,
            withParty,
            tradeData,
            position,
            paymentAmount,
            initialSettlementData
        );
        _updateTradeState(TRADE_STATE.INCEPTED);
        // @TODO
        // _pendingRequests[tradeId] = initiator; // unclear
        // _receivingParty = position == 1 ? initiator : withParty; // unclear
        _tradeData = tradeData;

        emit TradeIncepted(initiator, tradeId, tradeData);
    }

    function confirmTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external virtual override {
        address confirmer = msg.sender;
        // function call trade validator contract for checking trade data meet the requirement.
        bytes memory parsedTradeData = tradeData.parseHexStringToBytes();
        bytes memory parsedInitialSettlementData = initialSettlementData.parseHexStringToBytes();
        // @TODO validate trade data and settlement data
        // if (_tradeValidator.validateTradeData(parsedTradeData)) {
        //     revert TradeValidatorValidateFailed("trade-data");
        // }
        // if (_tradeValidator.validateSettlementData(parsedInitialSettlementData)) {
        //     revert TradeValidatorValidateFailed("settlement-data");
        // }
        string memory tradeId = _calculateTradeId(
            confirmer,
            withParty,
            tradeData,
            position,
            paymentAmount,
            initialSettlementData
        );
        // if _pendingRequests[tradeId]
        // delete _pendingRequests[tradeId]; // perform clear the request.
        _updateTradeState(TRADE_STATE.CONFIRMED);
        emit TradeConfirmed(confirmer, tradeId);

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
        string memory tradeId = _calculateTradeId(
            initiator,
            withParty,
            tradeData,
            position,
            paymentAmount,
            initialSettlementData
        );
        if (tradeId != _tradeId) {
            // revert ();
        }
        _updateTradeState(TRADE_STATE.INACTIVE);

        emit TradeCanceled(initiator, tradeId);
    }

    function requestTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external virtual override {
        address initiator = msg.sender;
        _terminationTerms = terminationTerms;
        bytes memory parsedTerminationTerms = terminationTerms.parseBytes();
        // @TODO validate termination terms
        // if (_tradeValidator.validateTerminationTerms(terminationTerms)) {
        //  revert TradeValidatorValidateFailed("termination-terms");
        //}
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
        address initiator = msg.sender;

        // emit SettlementRequested(initiator, tradeData, lastSettlementData);
    }

    function performSettlement(
        int256 settlementAmount,
        string memory settlementData
    ) external virtual {
        // emit SettlementDetermined(initiator, settlementAmount, settlementData);
        // afterTransfer(status, );
    }

    function afterTransfer(
        bool success,
        uint256 transactionId,
        string memory transactionData
    ) external {
        // if success
        // emit SettlementTransferred(tradeId, transactionData);
        // otherwise fail
        // emit SettlementFailed(tradeId, transactionData);
        // emit TradeTerminated("reason");
    }

    /**
     * @dev See {IERC6123OTC-partyA}.
     */
    function partyA() public view override returns (address) {
        return _partyA;
    }

    /**
     * @dev See {IERC6123OTC-partyB}.
     */
    function partyB() public view override returns (address) {
        return _partyB;
    }

    /**
     * @dev See {IERC6123OTC-tokenA}.
     */
    function tokenA() public view override returns (address) {
        return address(_tokenA);
    }

    /**
     * @dev See {IERC6123OTC-tokenB}.
     */
    function tokenB() public view override returns (address) {
        return address(_tokenB);
    }

    function tradeData() public view returns (string memory) {
        return _tradeData;
    }

    function tradeDataFormat() public pure virtual returns (TRADE_DATA_FORMAT) {
        return TRADE_DATA_FORMAT.BYTES;
    }

    function tradeId() public view returns (string memory) {
        return _tradeId;
    }

    function tradeState() public view returns (TRADE_STATE) {
        return _tradeState;
    }

    function terminationTerms() public view returns (string memory) {
        return _terminationTerms;
    }
}
