// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Block number comparator library
 * @author Kiwari Labs
 */

library BlockNumberComparators {
    function isBlockInPast(uint256 blockNumber) internal view returns (bool) {
        return block.number >= blockNumber;
    }

    function isFutureBlock(uint256 blockNumber) internal view returns (bool) {
        return block.number < blockNumber;
    }

    function isBlockBefore(uint256 blockNumber, uint256 targetBlockNumber) internal pure returns (bool) {
        return blockNumber < targetBlockNumber;
    }

    function isBlockAfter(uint256 blockNumber, uint256 targetBlockNumber) internal pure returns (bool) {
        return blockNumber > targetBlockNumber;
    }

    // compare {-1, 0, 1}
}