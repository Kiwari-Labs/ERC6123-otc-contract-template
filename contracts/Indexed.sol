// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Indexed
 * @author Kiwari Labs
 */
 
abstract contract Indexed {
    // @TODO adopt ERC-7201 for directly call data from storage by `eth_getStorageAt` instead `eth_call`.
    bytes32 private DEPLOYED_BLOCKNUMBER_SLOT =  0x0;
    bytes32 private LASTSEEN_BLOCKNUMBER_SLOT =  0x0;
    
    // uint256 public immutable DEPLOYED_BLOCKNUMBER;
    // uint256 public LASTSEEN_BLOCKNUMBER;

    constructor() {
        // DEPLOYED_BLOCKNUMBER = _blockNumberProvider();
        // LASTSEEN_BLOCKNUMBER = _blockNumberProvider();
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
        uint256 blockNumber = _blockNumberProvider();
        assembly {
            sstore(DEPLOYED_BLOCKNUMBER_SLOT.slot, blockNumber)
        }
    }

    // @TODO NatSpec
    function deployedAtBlockNumber() external view returns (uint256 blockNumber) {
        assembly {
            blockNumber := sload(DEPLOYED_BLOCKNUMBER_SLOT.slot)
        }
    }

    // @TODO NatSpec
    function latestTransactionAt() external view returns (uint256 blockNumber) {
        assembly {
            blockNumber := sload(LASTSEEN_BLOCKNUMBER_SLOT.slot)
        }
    }
}
