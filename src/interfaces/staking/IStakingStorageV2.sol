// SPDX-License-Identifier: MIT

import "./IStakingStorage.sol"; // For Stake struct definition

pragma solidity ^0.8.30;

/**
 * @title IStakingStorageV2 Interface
 * @notice Unified interface for consolidated staking storage
 */
interface IStakingStorageV2 {
    enum Sign {
        POSITIVE,
        NEGATIVE
    }

    struct Stake {
        uint128 amount;
        uint16 stakeDay;
        uint16 unstakeDay;
        uint16 daysLock;
        uint16 flags; // 2 bytes - pack multiple booleans
    }

    struct StakerInfo {
        uint128 totalStaked;
        uint32 stakesCounter;
        uint32 activeStakesNumber;
        uint16 lastCheckpointDay;
    }

    struct DailySnapshot {
        uint128 totalStakedAmount;
        uint32 totalStakesCount;
    }

    event CheckpointCreated(
        address indexed staker,
        uint16 indexed day,
        uint128 balance,
        uint32 stakesCount
    );

    // Stake Management
    function createStake(
        bytes32 stakeId,
        address staker,
        uint128 amount,
        uint16 daysLock,
        uint16 flags
    ) external;

    function removeStake(address staker, bytes32 stakeId) external;

    function getStake(bytes32 stakeId) external view returns (Stake memory);

    function isActiveStake(bytes32 stakeId) external view returns (bool);

    // Staker Management
    function getStakerInfo(
        address staker
    ) external view returns (StakerInfo memory);

    function getStakerBalance(address staker) external view returns (uint128);

    function getStakerBalanceAt(
        address staker,
        uint16 targetDay
    ) external view returns (uint128);

    function batchGetStakerBalances(
        address[] calldata stakers,
        uint16 targetDay
    ) external view returns (uint128[] memory);

    // Global Statistics
    function getDailySnapshot(
        uint16 day
    ) external view returns (DailySnapshot memory);

    function getCurrentTotalStaked() external view returns (uint128);

    // Pagination
    function getStakersPaginated(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory);

    function getTotalStakersCount() external view returns (uint256);

    function getStakerStakeIds(
        address staker
    ) external view returns (bytes32[] memory);
}
