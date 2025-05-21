// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Indexed
 * @author Kiwari Labs
 */

abstract contract Indexed {
    // @TODO adopt ERC-7201 for directly call data from storage by `eth_getStorageAt` instead `eth_call`.
    uint256 public immutable DEPLOYED_BLOCKNUMBER;
    uint256 public LASTSEEN_BLOCKNUMBER;

    constructor() {
        DEPLOYED_BLOCKNUMBER = _blockNumberProvider();
        LASTSEEN_BLOCKNUMBER = _blockNumberProvider();
    }

    /**
     * @notice some L2 use precompiled contract to get current block number.
     * @dev override this function if the network not use `block.number`.
     */
    function _blockNumberProvider() internal view virtual returns (uint256) {
        return block.number;
    }

    /**
     * @dev stamp last seen block number.
     */
    function _stampBlockNumber() internal {
        LASTSEEN_BLOCKNUMBER = _blockNumberProvider();
    }
}
