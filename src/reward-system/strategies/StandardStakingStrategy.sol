// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

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

    constructor(address _rewardToken, bool _isReStakingAllowed) {
        rewardToken = _rewardToken;
        isReStakingAllowed = _isReStakingAllowed;
    }

    function getParameters()
        external
        view
        override
        returns (
            string memory name,
            address _rewardToken,
            uint8 rewardLayer,
            Policy stackingPolicy,
            ClaimType claimType
        )
    {
        return (
            "Standard Staking Strategy",
            rewardToken,
            0, // Base Layer
            Policy.STACKABLE,
            ClaimType.ADMIN_GRANTED
        );
    }

    function calculateReward(
        address user,
        IStakingStorage.Stake memory stake,
        uint256 startDay,
        uint256 endDay
    ) external view override returns (uint256) {
        // This strategy's reward is based on the user's proportional share of the total weight in the pool.
        // The final reward is calculated in the RewardManager after the admin finalizes the pool with the totalEligibleWeight.
        // This function's primary job is to calculate the *user's individual weight* for the period.

        if (stake.unstakeDay != 0 && stake.unstakeDay < endDay) {
            // User withdrew during the pool.
            // We need to check the re-staking policy.
            if (!isReStakingAllowed) {
                return 0; // Not eligible if re-staking is disallowed and they withdrew.
            }
            // If re-staking is allowed, the weight is calculated only for the active period.
            endDay = stake.unstakeDay;
        }

        if (stake.stakeDay > endDay || startDay > endDay) {
            return 0; // Stake is not active within the calculation period.
        }

        uint256 effectiveStart = stake.stakeDay > startDay
            ? stake.stakeDay
            : startDay;
        uint256 effectiveDays = endDay - effectiveStart + 1;

        // The final weight is the stake amount multiplied by the number of days it was active in the pool.
        return stake.amount * effectiveDays;
    }
}
