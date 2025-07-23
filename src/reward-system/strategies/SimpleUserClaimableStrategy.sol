// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../../interfaces/reward/IRewardStrategy.sol";
import "../../interfaces/staking/IStakingStorage.sol";

/**
 * @title SimpleUserClaimableStrategy
 * @author @Tudmotu
 * @notice A simple USER_CLAIMABLE strategy for testing and demonstrating the logic.
 * @dev This strategy calculates reward based on stake amount and duration.
 */
contract SimpleUserClaimableStrategy is IRewardStrategy {
    address public immutable rewardToken;
    uint256 public immutable rewardRatePerDay;

    constructor(address _rewardToken, uint256 _rewardRatePerDay) {
        rewardToken = _rewardToken;
        rewardRatePerDay = _rewardRatePerDay;
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
            "Simple User Claimable Strategy",
            rewardToken,
            0, // Base Layer
            Policy.STACKABLE,
            ClaimType.USER_CLAIMABLE
        );
    }

    function calculateReward(
        address user,
        IStakingStorage.Stake memory stake,
        uint256 startTime,
        uint256 endTime
    ) external view override returns (uint256) {
        // Ensure the stake is active within the period
        if (
            stake.stakeDay > endTime ||
            (stake.unstakeDay != 0 && stake.unstakeDay < startTime)
        ) {
            return 0; // Stake not active in this period
        }

        uint256 effectiveStart = stake.stakeDay > startTime
            ? stake.stakeDay
            : startTime;
        uint256 effectiveEnd = (stake.unstakeDay == 0 ||
            stake.unstakeDay > endTime)
            ? endTime
            : stake.unstakeDay;

        if (effectiveEnd < effectiveStart) {
            return 0; // No effective days in period
        }

        uint256 daysActiveInPeriod = effectiveEnd - effectiveStart + 1;

        // Simple calculation: stake amount * rate per day * days active
        return stake.amount * rewardRatePerDay * daysActiveInPeriod;
    }
}
