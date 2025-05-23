// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {IERC6123} from "../IERC6123.sol";

interface IERC6123OTC is IERC6123 {
    /** @return address */
    function partyA() external view returns (address);

    /** @return address */
    function partyB() external view returns (address);

    /** @return address */
    function tokenA() external view returns (address);

    /** @return address  */
    function tokenB() external view returns (address);
}
