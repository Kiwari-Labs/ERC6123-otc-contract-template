// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ITradeValidator} from "../contracts/interfaces/ITradeValidator.sol";
import {ERC6123OTC} from "../contracts/ERC6123OTC.sol";

/**
 * @title Mock ERC6123 Over-The-Counter (OTC)
 * @author Kiwari Labs
 */

contract MockERC6123OTC is ERC6123OTC {
    constructor(address partyA, address partyB, IERC20 tokenA, IERC20 tokenB) ERC6123OTC(partyA, partyB, tokenA, tokenB) {}

    function setTradeValidator(ITradeValidator implementation) public {
        _updateTradeValidator(implementation);
    }
}
