// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

/// @title Template of using the Bilateral Agreement Template
/// @author Kiwari-labs
/// @notice this contract is abstract contract do not modify this contract.

import "../interfaces/IAgreement.sol";

abstract contract Agreement is IAgreement {
    uint32 private _version = 100;

    /// @notice Event

    /// @notice Error

    constructor(string memory name_) {
        _name = name_;
    }

    /// @dev increamental version if configuration change?
    function _bumpVersion() internal {
        _version += 10; // +10
        // emit
    }

    /// @dev increamental version if some parameter change?
    function _bumpPatch() internal {
        _version++; // +1
        // emit
    }

    /// @notice Returns the current version of the agreement
    /// @return The version number of the agreement
    function version() public view returns (uint32) {
        return _version;
    }

    /// @notice Returns the name of the agreement
    /// @return The name of the agreement
    function name() public view returns (string memory) {
        return _name;
    }

    /// @inheritdoc IAgreement
    function agreement(
        bytes memory x,
        bytes memory y
    ) public view override returns (bool) {
        return _verifyAgreement(x, y);
    }

    /// @dev Internal function to verify the agreement between party A and party B
    /// @param x The input parameters provided by party A
    /// @param y The input parameters provided by party B
    /// @return True if the agreement is valid, otherwise false
    function _verifyAgreement(
        bytes memory x,
        bytes memory y
    ) internal virtual returns (bool) {}
}
