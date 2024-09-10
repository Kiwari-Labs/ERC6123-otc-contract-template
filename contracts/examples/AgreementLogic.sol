// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

/// @title General Token Amount Agreement
/// @notice
/// @dev documentation of General Token Amount Agreement available at https://github.com/Kiwari-labs/
/// @author Kiwari-labs

import "../AddressCompartor.sol";
import "../IntComparator.sol";
import "../template/AgreementTemplate.sol";

contract GeneralTokenAgreement is AgreementTemplate {
    using IntComparator for uint256;
    using AddressCompartor for address;

    /// @notice error

    function _verifyAmountTokenA(
        uint inputTokenAAmount,
        uint requiredAmount
    ) private pure returns (bool) {
        return inputTokenAAmount.equal(requiredAmount);
    }

    function _verifyAmountTokenB(
        uint inputTokenBAmount,
        uint requiredAmount
    ) private pure returns (bool) {
        return inputTokenBAmount.equal(requiredAmount);
    }

    function _verifyBalanceTokenA(
        address tokenA,
        address bilateralAgreementContract,
        uint requiredAmountTokenA
    ) private pure returns (bool) {
        return
            (IERC20(tokenA).balanceOf(bilateralAgreementContract)).equal(
                requiredAmountTokenA
            );
    }

    function _verifyBalanceTokenB(
        address tokenB,
        address bilateralAgreementContract,
        uint requiredAmountTokenB
    ) private pure returns (bool) {
        return
            (IERC20(tokenB).balanceOf(bilateralAgreementContract)).equal(
                requiredAmountTokenB
            );
    }

    function _verifyBilaterlContract(
        address contractA,
        address contractB
    ) private pure returns (bool) {
        return contractA.equal(contractB);
    }

    function _verifyAgreement(
        bytes memory x,
        bytes memory y
    ) internal override returns (bool) {
        // #################### start your custom logic ####################
        // party A encoded token A amount
        uint amountTokenA = abi.decode(x[0], uint);
        // party B encoded token B amount
        uint amountTokenB = abi.decode(y[0], uint);
        // party A require token A
        uint requiredAmountTokenA = abi.decode(y[1], uint);
        // party B require token B
        uint requiredAmountTokenB = abi.decode(x[1], uint);
        // token A address
        address tokenA = abi.decode(x[2], address);
        // token B address
        address tokenB = abi.decode(y[2], address);
        // party A encode bilateral contract address
        address bilateralAgreementContractA = abi.decode(x[3], address);
        // party B encode bilateral contract address
        address bilateralAgreementContractB = abi.decode(y[3], address);
        require(
            _verifyBilaterlContract(
                bilateralAgreementContractA,
                bilateralAgreementContractB,
                "Invalid bilateral contract address"
            )
        );
        require(
            _verifyAmountTokenA(amountTokenA, requiredAmountTokenA),
            "Invalid encoded amount token A"
        );
        require(
            _verifyAmountTokenA(amountTokenB, requiredAmountTokenB),
            "Invalid encoded amount token B"
        );
        require(
            _verifyBalanceTokenA(amountTokenA, bilateralAgreementContract),
            "Invalid balanceOf token A on bilateral contract address"
        );
        require(
            _verifyBalanceTokenB(amountTokenB, bilateralAgreementContract),
            "Invalid balanceOf token B on bilateral contract address"
        );
        // #################### end your custom logic ####################
        // do not change the line below.
        return true;
    }
}
