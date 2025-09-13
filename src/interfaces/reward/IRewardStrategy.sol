// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IStakingStorage} from "../staking/IStakingStorage.sol";

interface IRewardStrategy {
    enum StrategyType {
        POOL_SIZE_INDEPENDENT, // Can calculate anytime (APR-style)
        POOL_SIZE_DEPENDENT // Requires BE calculation after pool ends - how much were staked during the pool
    }

    // --- CONFIGURATION VIEW FUNCTIONS ---

    function getName() external view returns (string memory);
    function getRewardToken() external view returns (address);
    function getRewardLayer() external view returns (uint8);
    function getStrategyType() external view returns (StrategyType);

    // --- CORE LOGIC ---

    /**
     * @notice Calculates reward for POOL_SIZE_INDEPENDENT strategies.
     */
    function calculateReward(
        address user,
        IStakingStorage.Stake calldata stake,
        uint16 poolStartDay,
        uint16 poolEndDay,
        uint16 lastClaimDay
    ) external view returns (uint256);

    /**
     * @notice Calculates reward for POOL_SIZE_DEPENDENT strategies.
     */
    function calculateReward(
        address user,
        IStakingStorage.Stake calldata stake,
        uint256 totalPoolWeight,
        uint256 totalRewardAmount,
        uint16 poolStartDay,
        uint16 poolEndDay
    ) external view returns (uint256);
}
