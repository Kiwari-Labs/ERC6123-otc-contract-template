// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Indexed
 * @author Kiwari Labs
 */
 
abstract contract Indexed {
    /** @custom:storage-location erc7201:indexed */
    struct IndexedStorage {
        uint256 deployedBlockNumber;        // slot:0x8eca1f781afde2be911869090c62fb7cfdc951e1ab735da6bf694cda2bf8d600
        uint256 latestInteractBlockNumber;  // slot:0x8eca1f781afde2be911869090c62fb7cfdc951e1ab735da6bf694cda2bf8d601
    }
    
    // keccak256(abi.encode(uint256(keccak256("indexed")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant INDEXED_STORAGE_LOCATION = 0x8eca1f781afde2be911869090c62fb7cfdc951e1ab735da6bf694cda2bf8d600;

    constructor() {
        uint256 blockNumber = _blockNumberProvider();
        IndexedStorage storage $ = _getIndexedStorage();
        $.deployedBlockNumber = blockNumber;
        $.latestInteractBlockNumber = blockNumber;
    }

    /**
     * @notice Returns a pointer to the contract's IndexedStorage struct.
     * @dev Uses a fixed storage slot derived from the storage location hash.
     * @return $ A storage reference to the IndexedStorage struct.
     */
    function _getIndexedStorage() private pure returns (IndexedStorage storage $) {
        assembly {
            $.slot := INDEXED_STORAGE_LOCATION
        }
    }

    /**
     * @notice Some L2s use a precompiled contract to get the current block number.
     * @dev Override this function if the network does not use `block.number`.
     * @return The current block number, either native or overridden.
     */
    function _blockNumberProvider() internal view virtual returns (uint256) {
        return block.number;
    }

    /**
     * @dev stamp last seen block number.
     */
    function _stampBlockNumber() internal {
        IndexedStorage storage $ = _getIndexedStorage();
        $.latestInteractBlockNumber =  _blockNumberProvider();
    }

    /**
     * @notice Returns the block number at which the contract was deployed.
     * @return uint256 The deployed block number.
     */
    function deployedBlockNumber() external view returns (uint256) {
        return _getIndexedStorage().deployedBlockNumber;
    }

     /**
     * @notice Returns the last block number at which the contract was interacted with.
     * @return uint256 The latest interaction block number.
     */
    function latestInteractBlockNumber() external view returns (uint256) {
        return _getIndexedStorage().latestInteractBlockNumber;
    }
}
