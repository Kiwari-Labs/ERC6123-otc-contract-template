// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Bool type comparator library
 */
library BoolComparators {
    function and(bool x, bool y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, eq(x, y))
            return(m, 0x20)
        }
    }

    function or(bool x, bool y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, or(x, y))
            return(m, 0x20)
        }
    }

    function isTrue(bool x) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, eq(x, 0x01))
            return(m, 0x20)
        }
    }

    function isFalse(bool x) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, iszero(x))
            return(m, 0x20)
        }
    }
}
