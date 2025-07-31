// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {StringBytes} from "./libraries/StringBytes.sol";
import {IERC6123OTC} from "./interfaces/ERC6123/extensions/IERC6123OTC.sol";
import {ITradeValidator} from "./interfaces/ITradeValidator.sol";
import {Indexed} from "./Indexed.sol";

/**
 * @title ERC6123 Over-The-Counter (OTC)
 * @author Kiwari Labs
 */
 
interface IStandardTradeValidator {
    function getValue(bytes memory settlementData) external view returns (uint256, uint256);
}

abstract contract ERC6123OTC is IERC6123OTC, Indexed {
    using SafeERC20 for IERC20;
    using Strings for string;
    using Strings for uint256;
    using StringBytes for string;

    enum TRADE_DATA_FORMAT {
        BYTES, // encode data with abi encode
        JSON,
        XML,
        URI // the data stored off-chain
    }

    enum TRADE_STATE {
        INACTIVE /** 0 */,
        INCEPTED /** 1 */,
        CONFIRMED /** 2 */,
        VALUATION /** 3 */,
        IN_TRANSFER /** 4 */,
        SETTLED /** 5 */,
        IN_TERMINATED /** 6 */,
        TERMINATED
    }
    /** 7 */

    /** storage layout */
    address private _partyA;
    address private _partyB;

    IERC20 private _tokenA;
    IERC20 private _tokenB;

    ITradeValidator private _tradeValidator;

    TRADE_STATE private _tradeState;
    TRADE_STATE private _requestTerminatedAt;

    string private _tradeId;
    string private _tradeData;
    string private _terminationTerms;
    mapping(string => address) _pendingRequests;

    uint256 private _counter;

    /** custom errors */
    error ERC6123InvalidPartyAddress();
    error ERC6123InvalidTradeState(uint8 current, uint8 expected);
    error ERC6123TradeValidatorValidateFailed(string state);

    /** additional errors revert code
     *  all this error will not inherit to the implementation contract.
     * "0x05da3924" from bytes4(keccak256("self trade is not allowed"));
     * "0xb01ec053" from bytes4(keccak256("self confirm is not allowed"));
     * "0xe36270fc" from bytes4(keccak256("position greater than 0 not allowed"));
     * "0x9d7c8c0e" from bytes4(keccak256("paymentAmount greater than 0 not allowed"));
     * "0xfca1be26" from bytes4(keccak256("afterTransfer not implemented"));
     * "0xa1b843d9" from bytes4(keccak256("trade id not exists"));
     */

    /** events */
    event TradeValidatorChanged(address oldImplementation, address newImplementation);

    modifier whenTradeInactive() {
        _requireState(uint8(TRADE_STATE.INACTIVE));
        _;
    }

    modifier whenTradeIncepted() {
        _requireState(uint8(TRADE_STATE.INCEPTED));
        _;
    }

    modifier whenConfirmed() {
        _requireState(uint8(TRADE_STATE.CONFIRMED));
        _;
    }

    modifier whenValuation() {
        _requireState(uint8(TRADE_STATE.VALUATION));
        _;
    }

    modifier whenInTransfer() {
        _requireState(uint8(TRADE_STATE.IN_TRANSFER));
        _;
    }

    modifier whenSettled() {
        _requireState(uint8(TRADE_STATE.SETTLED));
        _;
    }

    modifier whenInTerminated() {
        _requireState(uint8(TRADE_STATE.IN_TERMINATED));
        _;
    }

    modifier onlyInvolvedParty() {
        address initiator = msg.sender;
        if (initiator != _partyA && initiator != _partyB) {
            revert ERC6123InvalidPartyAddress();
        }
        _;
    }

    constructor(address partyA, address partyB, IERC20 tokenA, IERC20 tokenB) Indexed() {
        _partyA = partyA;
        _partyB = partyB;
        _tokenA = tokenA;
        _tokenB = tokenB;
    }

    // @TODO NatSpec comment
    function _requireState(uint8 expected) private {
        uint8 current = uint8(_tradeState);
        if (current != expected) {
            revert ERC6123InvalidTradeState(current, expected);
        }
    }

    // @TODO NatSpec comment
    function _calculateTradeId(
        address initiator,
        address withParty,
        string memory tradeData,
        string memory initialSettlementData
    ) private returns (string memory) {
        return
            uint256(keccak256(abi.encode(initiator, withParty, tradeData, initialSettlementData, _counter, block.chainid))).toHexString();
    }

    // @TODO NatSpec comment
    function _updateTradeValidator(ITradeValidator implementation) internal {
        if (address(implementation) == address(0)) {
            revert();
        }
        address oldImplementation = address(_tradeValidator);
        _tradeValidator = implementation;

        emit TradeValidatorChanged(oldImplementation, address(implementation));
    }

    // @TODO NatSpec comment
    function inceptTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external virtual override onlyInvolvedParty returns (string memory) {
        TRADE_STATE tradeState = _tradeState;
        if (tradeState != TRADE_STATE.INACTIVE && tradeState != TRADE_STATE.SETTLED) {
            revert ERC6123InvalidTradeState(uint8(tradeState), 50); // SETTLED and INACTIVE
        }
        address initiator = msg.sender;
        if (initiator == withParty) revert("0x05da3924");
        if (position != 0) revert("0xe36270fc");
        if (paymentAmount != 0) revert("0x9d7c8c0e");

        string memory tradeId = _calculateTradeId(initiator, withParty, tradeData, initialSettlementData);
        _pendingRequests[tradeId] = withParty;

        _tradeId = tradeId;
        _tradeData = tradeData;
        _tradeState = TRADE_STATE.INCEPTED;
        _stampBlockNumber();

        emit TradeIncepted(initiator, tradeId, tradeData);

        return tradeId;
    }

    // @TODO NatSpec comment
    function confirmTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external virtual override onlyInvolvedParty whenTradeIncepted {
        address confirmer = msg.sender;
        if (confirmer == withParty) revert("0x05da3924");
        if (position != 0) revert("0xe36270fc");
        if (paymentAmount != 0) revert("0x9d7c8c0e");

        string memory tradeId = _calculateTradeId(withParty, confirmer, tradeData, initialSettlementData);
        if (_pendingRequests[tradeId] != confirmer) revert("0xb01ec053");

        // function call trade validator contract for checking trade data meet the requirement.
        bytes memory parsedTradeData = tradeData.parseHexStringToBytes();
        bytes memory parsedInitialSettlementData = initialSettlementData.parseHexStringToBytes();
        if (!_tradeValidator.validateTradeData(parsedTradeData)) {
            revert ERC6123TradeValidatorValidateFailed("trade-data");
        }
        if (!_tradeValidator.validateSettlementData(parsedInitialSettlementData)) {
            revert ERC6123TradeValidatorValidateFailed("init-settlement-data");
        }

        _tradeState = TRADE_STATE.CONFIRMED;
        _stampBlockNumber();

        emit TradeConfirmed(confirmer, tradeId);
    }

    // @TODO NatSpec comment
    function cancelTrade(
        address withParty,
        string memory tradeData,
        int position,
        int256 paymentAmount,
        string memory initialSettlementData
    ) external virtual override onlyInvolvedParty whenTradeIncepted {
        address initiator = msg.sender;
        string memory tradeId = _calculateTradeId(initiator, withParty, tradeData, initialSettlementData);
        if (!tradeId.equal(_tradeId)) revert("0xa1b843d9");

        bytes memory parsedTradeData = tradeData.parseHexStringToBytes();
        bytes memory parsedInitialSettlementData = initialSettlementData.parseHexStringToBytes();
        if (!_tradeValidator.validateTradeData(parsedTradeData)) {
            revert ERC6123TradeValidatorValidateFailed("trade-data");
        }
        if (!_tradeValidator.validateSettlementData(parsedInitialSettlementData)) {
            revert ERC6123TradeValidatorValidateFailed("init-settlement-data");
        }

        // perform clear storage
        delete _tradeId;
        delete _tradeData;
        delete _tradeState;
        delete _terminationTerms;
        delete _pendingRequests[tradeId];

        _counter++;
        _stampBlockNumber();

        emit TradeCanceled(initiator, tradeId);
    }

    /**
     * @param tradeId trade id
     * @param terminationPayment termination payment
     * @param terminationTerms encoded payload data
     */
    function requestTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external virtual override onlyInvolvedParty whenValuation {
        address initiator = msg.sender;
        address responder = initiator == _partyA ? _partyB : _partyA;
        string memory terminationTradeId = uint256(keccak256(abi.encode(tradeId, "termination"))).toHexString();
        _pendingRequests[terminationTradeId] = responder;

        bytes memory parsedTerminationTerms = terminationTerms.parseHexStringToBytes();
        if (!_tradeValidator.validateTerminationTerms(parsedTerminationTerms)) {
            revert ERC6123TradeValidatorValidateFailed("termination-terms");
        }

        _terminationTerms = terminationTerms;
        _requestTerminatedAt = _tradeState;
        _tradeState = TRADE_STATE.IN_TERMINATED;
        _stampBlockNumber();

        emit TradeTerminationRequest(initiator, tradeId, terminationPayment, terminationTerms);
    }

    /**
     * @param tradeId trade id
     * @param terminationPayment termination payment
     * @param terminationTerms encoded payload data
     */
    function confirmTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external virtual override onlyInvolvedParty whenInTerminated {
        address confirmer = msg.sender;
        string memory terminationTradeId = uint256(keccak256(abi.encode(tradeId, "termination"))).toHexString();
        if (_pendingRequests[terminationTradeId] != confirmer) revert("0xb01ec053");
        bytes memory parsedTerminationTerms = terminationTerms.parseHexStringToBytes();
        if (!_tradeValidator.validateTerminationTerms(parsedTerminationTerms)) {
            revert ERC6123TradeValidatorValidateFailed("termination-terms");
        }

        // perform clear storage
        delete _pendingRequests[terminationTradeId];
        delete _terminationTerms;
        delete _tradeId;
        delete _tradeData;

        // if the request to terminate at incepted status will be terminated this contract.
        if (_requestTerminatedAt == TRADE_STATE.INCEPTED) {
            _tradeState = TRADE_STATE.TERMINATED;
        } else {
            delete _tradeState;
        }

        _counter++;
        _stampBlockNumber();

        emit TradeTerminationConfirmed(confirmer, tradeId, terminationPayment, terminationTerms);

        // @TODO get callback from?
        emit TradeTerminated("reason");
    }

    /**
     * @param tradeId trade id
     * @param terminationPayment termination payment
     * @param terminationTerms encoded payload data
     */
    function cancelTradeTermination(
        string memory tradeId,
        int256 terminationPayment,
        string memory terminationTerms
    ) external virtual override onlyInvolvedParty whenInTerminated {
        address confirmer = msg.sender;
        address responder = confirmer == _partyA ? _partyB : _partyA;
        string memory terminationTradeId = uint256(keccak256(abi.encode(tradeId, "termination"))).toHexString();
        if (_pendingRequests[terminationTradeId] != confirmer) revert("0xb01ec053");

        bytes memory parsedTerminationTerms = terminationTerms.parseHexStringToBytes();
        if (!_tradeValidator.validateTerminationTerms(parsedTerminationTerms)) {
            revert ERC6123TradeValidatorValidateFailed("termination-terms");
        }

        _pendingRequests[_tradeId] = responder;
        _tradeState = TRADE_STATE.INCEPTED;
        _stampBlockNumber();

        emit TradeTerminationCanceled(confirmer, tradeId, terminationTerms);
    }

    // @TODO NatSpec comment
    function initiateSettlement() external virtual override onlyInvolvedParty whenConfirmed {
        address initiator = msg.sender;
        address responder = initiator == _partyA ? _partyB : _partyA;
        string memory settlementTradeId = uint256(keccak256(abi.encode(_tradeId, "settlement"))).toHexString();

        _pendingRequests[settlementTradeId] = responder;
        _tradeState = TRADE_STATE.VALUATION;
        _stampBlockNumber();

        emit SettlementRequested(initiator, _tradeData, "");
    }

    // @TODO NatSpec comment
    function performSettlement(
        int256 settlementAmount,
        string memory settlementData
    ) external virtual override onlyInvolvedParty whenValuation {
        address initiator = msg.sender;
        if (_pendingRequests[_tradeId] != initiator) revert("0xb01ec053");

        bytes memory parseSettlementData = settlementData.parseHexStringToBytes();
        if (!_tradeValidator.validateSettlementData(parseSettlementData)) {
            revert ERC6123TradeValidatorValidateFailed("settlement-data");
        }
        bytes memory parseTradeData = _tradeData.parseHexStringToBytes();

        (uint256 valueA, uint256 valueB) = IStandardTradeValidator(address(_tradeValidator)).getValue(parseTradeData);
        bool txn1 = _tokenA.trySafeTransferFrom(_partyA, _partyB, valueA);
        bool txn2 = _tokenB.trySafeTransferFrom(_partyB, _partyA, valueB);

        // perform clear storage
        delete _pendingRequests[_tradeId];
        delete _tradeId;
        delete _tradeData;

        _counter++;
        _tradeState == TRADE_STATE.INCEPTED;
        _stampBlockNumber();

        if (txn1 && txn2) {
            emit SettlementDetermined(initiator, settlementAmount, settlementData);
        } else {
            emit SettlementFailed("error");
        }
    }

    // @TODO NatSpec comment
    function afterTransfer(bool success, uint256 transactionId, string memory transactionData) external virtual override {
        // afterTransfer not required.
        revert("0xfca1be26");
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

    function tradeCount() public view returns (uint256) {
        return _counter;
    }

    function tradeData() public view returns (string memory) {
        return _tradeData;
    }

    function tradeDataFormat() public pure virtual returns (TRADE_DATA_FORMAT) {
        return TRADE_DATA_FORMAT.BYTES;
    }

    function tradeValidator() public view returns (address) {
        return address(_tradeValidator);
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
