// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.8.0 <0.9.0;

/** @title Mock ERC6123OTC
 * @author Kiwari Labs
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC6123OTC} from "../contracts/ERC6123OTC.sol";

contract MockERC6123OTC is ERC6123OTC {
    constructor(
        address partyA,
        address partyB,
        IERC20 tokenA,
        IERC20 tokenB
    ) ERC6123OTC(partyA, partyB, tokenA, tokenB) {}

    // set trade validator contract function
}
