// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../../interfaces/reward/IRewardStrategy.sol";
import "../../interfaces/staking/IStakingStorage.sol";

/**
 * @title FullStakingStrategy
 * @author @Tudmotu
 * @notice A strategy for a special bonus for early, long-term stakers.
 * @dev This is an ADMIN_GRANTED strategy. It checks for eligibility based on stake timing.
 */
contract FullStakingStrategy is IRewardStrategy {
    address public immutable rewardToken;
    uint16 public immutable gracePeriodInDays;

    constructor(address _rewardToken, uint16 _gracePeriodInDays) {
        rewardToken = _rewardToken;
        gracePeriodInDays = _gracePeriodInDays;
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
            "Full Staking Bonus Strategy",
            rewardToken,
            1, // Bonus Layer
            Policy.STACKABLE,
            ClaimType.ADMIN_GRANTED
        );
    }

    function calculateReward(
        address user,
        IStakingStorage.Stake memory stake,
        uint256 startDay, // Corresponds to the parent pool's startDay
        uint256 endDay // Corresponds to the parent pool's endDay
    ) external view override returns (uint256) {
        // This function is used to determine a user's eligibility and their weight.
        // The final reward is calculated in the RewardManager.

        // Condition 1: Stake must have started within the grace period.
        bool startedEarly = stake.stakeDay < (startDay + gracePeriodInDays);

        // Condition 2: Stake must not have been withdrawn before or on the end day of the pool.
        bool heldUntilEnd = stake.unstakeDay == 0 || stake.unstakeDay >= endDay;

        if (startedEarly && heldUntilEnd) {
            // If eligible, the user's weight is simply their stake amount.
            // The time-weighting is handled by the StandardStakingStrategy for the cyclical rewards.
            return stake.amount;
        }

        return 0; // Not eligible for the bonus.
    }
}
