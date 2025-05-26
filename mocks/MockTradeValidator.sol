// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.8.0 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AddressComparators} from "../contracts/libraries/comparators/AddressComparators.sol";
import {BlockNumberComparators} from "../contracts/libraries/comparators/BlockNumberComparators.sol";
import {UIntComparators} from "../contracts/libraries/comparators/UIntComparators.sol";
import {IERC6123OTC} from "../contracts/interfaces/ERC6123/extensions/IERC6123OTC.sol";
import {AbstractTradeValidator} from "../contracts/AbstractTradeValidator.sol";

/**
 * @title Mock Standard Trade Validator
 * @author Kiwari Labs
 */

contract MockTradeValidator is AbstractTradeValidator {
    using AddressComparators for address;
    using BlockNumberComparators for uint256;
    using UIntComparators for uint256;

    constructor(
        string memory tradeDataABI,
        string memory settlementDataABI,
        string memory terminationTermsABI
    ) AbstractTradeValidator(tradeDataABI, settlementDataABI, terminationTermsABI) {}

    function _checkAllowance(address token, address owner, address OTCContract, uint256 requiredAmountToken) private view returns (bool) {
        return
            IERC20(token).balanceOf(owner).greaterThanOrEqualTo(requiredAmountToken) &&
            IERC20(token).allowance(owner, OTCContract).greaterThanOrEqualTo(requiredAmountToken);
    }

    function _validateTradeData(bytes memory tradeData) internal view override returns (bool) {
        // decode amounts and addresses from both parties
        (uint256 partyAGetTokenB, uint256 partyBGetTokenA, address OTCContract) = abi.decode(tradeData, (uint, uint, address));

        // variable
        address partyA = IERC6123OTC(OTCContract).partyA();
        address partyB = IERC6123OTC(OTCContract).partyB();
        address tokenA = IERC6123OTC(OTCContract).tokenA();
        address tokenB = IERC6123OTC(OTCContract).tokenB();

        // condition
        require(_checkAllowance(tokenA, partyA, OTCContract, partyBGetTokenA), "");
        require(_checkAllowance(tokenB, partyB, OTCContract, partyAGetTokenB), "");

        return true;
    }

    function _validateSettlementData(bytes memory settlementData) internal view override returns (bool) {
        // skip validate by decode input
        return abi.decode(settlementData, (bool));
    }

    function _validateTerminationTerms(bytes memory terminationTerms) internal view override returns (bool) {
        // skip validate by decode input
        return abi.decode(terminationTerms, (bool));
    }

    function getValue(bytes memory settlementData) external view returns (uint256, uint256) {
        (uint256 a, uint256 b) = abi.decode(settlementData, (uint256, uint256));

        return (a, b);
    }
}
