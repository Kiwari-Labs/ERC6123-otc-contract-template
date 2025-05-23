// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Uint256 type comparator
 * @author Kiwari Labs
 */

library UIntComparators {
    function equal(uint256 x, uint256 y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, eq(x, y))
            return(m, 0x20)
        }
    }

    function notEqual(uint256 x, uint256 y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, not(eq(x, y)))
            return(m, 0x20)
        }
    }

    function greaterThan(uint256 x, uint256 y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, gt(x, y))
            return(m, 0x20)
        }
    }

    function greaterThanOrEqualTo(uint256 x, uint256 y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            if gt(x, y) {
                mstore(m, 0x01)
                return(m, 0x20)
            }
            if eq(x, y) {
                mstore(m, 0x01)
                return(m, 0x20)
            }
            return(m, 0x20)
        }
    }

    function lessThan(uint x, uint256 y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, lt(x, y))
            return(m, 0x20)
        }
    }

    function lessThanOrEqualTo(uint256 x, uint256 y) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            if lt(x, y) {
                mstore(m, 0x01)
                return(m, 0x20)
            }
            if eq(x, y) {
                mstore(m, 0x01)
                return(m, 0x20)
            }
            return(m, 0x20)
        }
    }

    function isZero(uint256 x) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, iszero(x))
            return(m, 0x20)
        }
    }

    function isNotZero(uint256 x) internal pure returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, not(iszero(x)))
            return(m, 0x20)
        }
    }

    function compare(uint256 x, uint256 y) internal pure returns (int8) {
        assembly {
            let m := mload(0x40)
            if lt(x, y) {
                mstore(m, 0xFF)
                return(m, 0x20)
            }
            if gt(x, y) {
                mstore(m, 0x01)
                return(m, 0x20)
            }
        }
    }
}
