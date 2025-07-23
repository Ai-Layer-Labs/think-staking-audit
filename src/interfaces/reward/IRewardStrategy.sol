// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../staking/IStakingStorage.sol";

/**
 * @title IRewardStrategy
 * @author @Tudmotu
 * @notice The universal interface for all reward calculation strategies.
 */
interface IRewardStrategy {
    /**
     * @dev Defines how a strategy interacts with others in the same layer.
     * STACKABLE: Can be combined with other STACKABLE strategies.
     * EXCLUSIVE_IN_LAYER: Mutually exclusive with all other strategies in the same layer.
     */
    enum Policy {
        STACKABLE,
        EXCLUSIVE_IN_LAYER
    }

    /**
     * @dev Defines how a strategy is funded and claimed.
     * PRE_FUNDED: The strategy has a specific budget allocated to it in advance by an admin.
     * CALCULATED_ON_DEMAND: The strategy calculates its reward based on external factors.
     */
    enum FundingMode {
        PRE_FUNDED,
        CALCULATED_ON_DEMAND
    }

    /**
     * @dev Defines how a reward is claimed by the user.
     * USER_CLAIMABLE: Users can claim at any time.
     * ADMIN_GRANTED: An admin must process the pool before users can claim.
     */
    enum ClaimType {
        USER_CLAIMABLE,
        ADMIN_GRANTED
    }

    /**
     * @notice Returns the key parameters of the strategy.
     * @return name The name of the strategy.
     * @return rewardToken The address of the ERC20 token used for rewards.
     * @return rewardLayer The priority layer of the reward.
     * @return stackingPolicy The policy for combining with other strategies.
     * @return claimType The method by which rewards are claimed.
     */
    function getParameters()
        external
        view
        returns (
            string memory name,
            address rewardToken,
            uint8 rewardLayer,
            Policy stackingPolicy,
            ClaimType claimType
        );

    /**
     * @notice The universal function to calculate rewards for a given stake over a specific period.
     * @param user The address of the staker.
     * @param stake The user's stake data.
     * @param startDay The start of the calculation period (day).
     * @param endDay The end of the calculation period (day).
     * @return The calculated reward amount.
     */
    function calculateReward(
        address user,
        IStakingStorage.Stake memory stake,
        uint256 startDay,
        uint256 endDay
    ) external view returns (uint256);
}
