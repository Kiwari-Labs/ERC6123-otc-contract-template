// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Address type comparator library
 * @author Kiwari Labs
 */

library AddressComparators {
    function equal(address x, address y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, eq(x, y))
            return(m, 0x20)
        }
    }

    function notEqual(address x, address y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, not(eq(x, y)))
            return(m, 0x20)
        }
    }

    function isZeroAddress(address x) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, iszero(x))
            return(m, 0x20)
        }
    }

    function isNotZeroAddress(address x) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, not(iszero(x)))
            return(m, 0x20)
        }
    }
}
