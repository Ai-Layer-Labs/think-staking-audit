// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

/**
 * @title IStakingStorage Interface
 * @notice Unified interface for consolidated staking storage
 */
interface IStakingStorage {
    struct Stake {
        uint128 amount;
        uint16 stakeDay;
        uint16 unstakeDay;
        uint16 daysLock;
        bool isFromClaim;
    }

    struct StakerInfo {
        uint128 totalStaked;
        uint16 stakesCounter;
        uint16 activeStakesNumber;
        uint16 lastCheckpointDay;
    }

    struct DailySnapshot {
        uint128 totalStakedAmount;
        uint16 totalStakesCount;
    }

    // Events
    event Staked(
        address indexed staker,
        bytes32 indexed stakeId,
        uint128 amount,
        uint16 indexed stakeDay,
        uint16 daysLock,
        bool isFromClaim
    );

    event Unstaked(
        address indexed staker,
        bytes32 indexed stakeId,
        uint16 indexed unstakeDay,
        uint128 amount
    );

    event CheckpointCreated(
        address indexed staker,
        uint16 indexed day,
        uint128 balance,
        uint16 stakesCount
    );

    // Stake Management
    function createStake(
        address staker,
        bytes32 stakeId,
        uint128 amount,
        uint16 daysLock,
        bool isFromClaim
    ) external;

    function removeStake(address staker, bytes32 stakeId) external;

    function getStake(
        address staker,
        bytes32 stakeId
    ) external view returns (Stake memory);

    function isActiveStake(
        address staker,
        bytes32 stakeId
    ) external view returns (bool);

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

    // Temporal Query Functions
    function getStakesExceedingDuration(
        address staker,
        uint16 minDays
    ) external view returns (bytes32[] memory);

    function getStakesByDurationRange(
        address staker,
        uint16 minDays,
        uint16 maxDays
    ) external view returns (bytes32[] memory);

    function getActiveStakesOnDay(
        address staker,
        uint16 targetDay
    ) external view returns (bytes32[] memory);

    function getStakesByDurationOnDay(
        address staker,
        uint16 targetDay,
        uint16 minDuration,
        bool includeGreater
    ) external view returns (bytes32[] memory);

    function batchGetStakeInfo(
        address staker,
        bytes32[] calldata stakeIds
    ) external view returns (Stake[] memory);

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
}
