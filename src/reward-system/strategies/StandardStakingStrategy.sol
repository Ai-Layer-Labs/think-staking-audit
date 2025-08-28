// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../../interfaces/reward/IRewardStrategy.sol";
import "../../interfaces/staking/IStakingStorage.sol";

/**
 * @title StandardStakingStrategy
 * @author @Tudmotu
 * @notice A strategy for calculating rewards for standard, cyclical pools.
 * @dev This is an ADMIN_GRANTED strategy. Rewards are calculated based on stake weight and duration within the pool.
 */
contract StandardStakingStrategy is IRewardStrategy {
    address public immutable rewardToken;
    bool public immutable isReStakingAllowed;

    uint16 public immutable MINIMUM_REWARDABLE_DURATION = 7;

    error MethodNotSupported();

    constructor(address _rewardToken) {
        rewardToken = _rewardToken;
    }

    function getName() external pure override returns (string memory) {
        return "Standard Staking Strategy";
    }

    function getRewardToken() external view override returns (address) {
        return rewardToken;
    }

    function getStrategyType() external pure override returns (StrategyType) {
        return StrategyType.POOL_SIZE_DEPENDENT;
    }

    function calculateReward(
        address, // user
        IStakingStorage.Stake calldata stake,
        uint256 totalPoolWeight,
        uint256 totalRewardAmount,
        uint16 poolStartDay,
        uint16 poolEndDay,
        uint16 lastClaimDay
    ) external pure returns (uint256) {
        // Eligibility checks:
        if (
            lastClaimDay > 0 || // 1. Not claimed yet.
            totalPoolWeight == 0 || // 2. Pool has it's weight calculated.
            stake.stakeDay > poolEndDay || // 3. Staked past the pool end day.
            // 4. Unstaked before the pool end day.
            (stake.unstakeDay > 0 && stake.unstakeDay <= poolEndDay)
        ) {
            return 0;
        }

        uint256 effectiveStart = stake.stakeDay > poolStartDay
            ? stake.stakeDay
            : poolStartDay;

        uint256 effectiveDays = poolEndDay - effectiveStart;
        uint256 userWeight = stake.amount * effectiveDays; // 81000

        if (effectiveDays < MINIMUM_REWARDABLE_DURATION) {
            // 2
            return 0; // No reward if stake duration is too short
        }

        // Step 2: Calculate and return the final reward.
        return (userWeight * totalRewardAmount) / totalPoolWeight;
    }
}
