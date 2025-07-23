// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IRewardManager {
    event ImmediateRewardClaimed(
        address indexed user,
        uint32 indexed strategyId,
        bytes32 indexed stakeId,
        uint256 amount,
        uint256 fromTimestamp,
        uint256 toTimestamp
    );

    event GrantedRewardsClaimed(
        address indexed user,
        uint256 totalAmount,
        uint256 rewardCount
    );

    event StrategyFunded(uint32 indexed strategyId, uint256 amount);
}
