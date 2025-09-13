// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../../interfaces/reward/IRewardStrategyV2.sol";
import "../../interfaces/staking/IStakingStorage.sol";

/**
 * @title StandardStakingStrategy
 * @author @Tudmotu
 * @notice A strategy for calculating rewards for standard, cyclical pools.
 * @dev This is an ADMIN_GRANTED strategy. Rewards are calculated based on stake weight and duration within the pool.
 */
contract StandardStakingStrategyV2 is IRewardStrategyV2 {
    address public immutable rewardToken;
    bool public immutable isReStakingAllowed;

    uint16 public immutable MINIMUM_REWARDABLE_DURATION;

    error MethodNotSupported();

    constructor(address _rewardToken, uint16 _minimumRewardableDuration) {
        rewardToken = _rewardToken;
        MINIMUM_REWARDABLE_DURATION = _minimumRewardableDuration;
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
        CalculationData calldata calculationData,
        bytes calldata
    ) external view returns (uint256) {
        (
            uint16 stakeDay,
            uint16 unstakeDay,
            uint128 stakeAmount,
            IRewardStrategyV2.PoolData memory pool,
            uint16 lastClaimDay
        ) = (
                calculationData.stake.stakeDay,
                calculationData.stake.unstakeDay,
                calculationData.stake.amount,
                calculationData.pool,
                calculationData.lastClaimDay
            );
        // Eligibility checks:
        if (
            lastClaimDay > 0 || // 1. Not claimed yet.
            pool.weight == 0 || // 2. Pool has it's weight calculated.
            stakeDay > pool.endDay || // 3. Staked past the pool end day.
            // 4. Unstaked before the pool end day.
            (unstakeDay > 0 && unstakeDay <= pool.endDay)
        ) {
            return 0;
        }

        uint256 effectiveStart = stakeDay > pool.startDay
            ? stakeDay
            : pool.startDay;

        uint256 effectiveDays = pool.endDay - effectiveStart;
        uint256 userWeight = stakeAmount * effectiveDays; // 81000

        if (effectiveDays < MINIMUM_REWARDABLE_DURATION) {
            return 0; // No reward if stake duration is too short
        }

        // Step 2: Calculate and return the final reward.
        return (userWeight * pool.reward) / pool.weight;
    }
}
