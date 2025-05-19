// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Timestamp comparator library
 * @author Kiwari Labs
 */

library TimestampComparators {
    function _isValid(uint256 unixtimestamp) private pure {
        // if timestamp before 1970-01-01T00:00:00Z revert
        assembly {
            if iszero(unixtimestamp) {
                // mstore(0x00, 0x00) // revert message 
                revert(0x00, 0x20)
            }
        }
    }

    function isTimestampInPast(uint256 timestamp) internal view returns (bool) {
        _isValid(timestamp);
        return block.timestamp >= timestamp;
    }

    function isFutureTimestamp(uint256 timestamp) internal view returns (bool) {
        _isValid(timestamp);
        return block.timestamp < timestamp;
    }

    function isTimestampBefore(uint256 timestamp, uint256 targetTimestamp) internal pure returns (bool) {
        _isValid(timestamp);
        _isValid(targetTimestamp);
        return timestamp < targetTimestamp;
    }

    function isTimestampAfter(uint256 timestamp, uint256 targetTimestamp) internal pure returns (bool) {
        _isValid(timestamp);
        _isValid(targetTimestamp);
        return timestamp < targetTimestamp;
    }
}