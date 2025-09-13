// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "./IStakingStorage.sol"; // For Stake struct definition

/**
 * @title IStakingVaultV2 Interface
 * @notice The primary entry point for all stake-related data and actions.
 */
interface IStakingVaultV2 {
    function getStake(
        bytes32 stakeId
    ) external view returns (IStakingStorage.Stake memory);

    function getStakerFromId(bytes32 stakeId) external pure returns (address);

    function getVersionFromId(bytes32 stakeId) external pure returns (uint8);

    function getCounterFromId(bytes32 stakeId) external pure returns (uint32);
}
