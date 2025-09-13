// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../../interfaces/reward/IRewardStrategyV2.sol";
import "../../interfaces/staking/IStakingStorage.sol";

/**
 * @title FullStakingStrategy
 * @author @Tudmotu
 * @notice A strategy that rewards stakers who keep their stake for the entire duration of a parent pool.
 * @dev This is an ADMIN_GRANTED strategy. It returns the stake amount as the weight for final calculation.
 */
contract FullStakingStrategyV2 is IRewardStrategyV2 {
    address public immutable rewardToken;
    uint16 public immutable gracePeriod; // Grace period in days.

    error MethodNotSupported();

    constructor(address _rewardToken, uint16 _gracePeriod) {
        rewardToken = _rewardToken;
        gracePeriod = _gracePeriod;
    }

    function getName() external pure override returns (string memory) {
        return "Full Staking Strategy";
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
        if (
            calculationData.lastClaimDay > 0 || // 1. Not claimed yet.
            calculationData.pool.weight == 0 || // 2. Pool has it's weight calculated.
            calculationData.stake.stakeDay >
            (calculationData.pool.startDay + gracePeriod) || // 3. Staked within grace period.
            // 4. Unstaked before the pool end day.
            (calculationData.stake.unstakeDay > 0 &&
                calculationData.stake.unstakeDay <= calculationData.pool.endDay)
        ) {
            return 0;
        }

        uint256 userWeight = calculationData.stake.amount * 90;

        return
            (userWeight * calculationData.pool.reward) /
            calculationData.pool.weight;
    }
}
