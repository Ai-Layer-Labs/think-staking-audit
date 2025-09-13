// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../../interfaces/reward/IRewardStrategyV2.sol";
import "../../interfaces/staking/IStakingStorage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title FullStakingStrategy
 * @author @Tudmotu
 * @notice A strategy that rewards stakers who keep their stake for the entire duration of a parent pool.
 * @dev This is an ADMIN_GRANTED strategy. It returns the stake amount as the weight for final calculation.
 */
contract FullStakingStrategy_WhiteListed is IRewardStrategyV2 {
    using EnumerableSet for EnumerableSet.AddressSet;
    address public immutable rewardToken;
    uint16 public immutable gracePeriod; // Grace period in days.
    address[] public whiteListedStakers;
    EnumerableSet.AddressSet private _whiteListedStakersSet;
    error MethodNotSupported();

    constructor(
        address _rewardToken,
        uint16 _gracePeriod,
        address[] memory _whiteListedStakers
    ) {
        rewardToken = _rewardToken;
        gracePeriod = _gracePeriod;
        whiteListedStakers = _whiteListedStakers;
        for (uint256 i = 0; i < _whiteListedStakers.length; i++) {
            _whiteListedStakersSet.add(_whiteListedStakers[i]);
        }
    }

    function getName() external pure override returns (string memory) {
        return "Full Staking Strategy - White Listed";
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
            address staker,
            uint16 stakeDay,
            uint16 unstakeDay,
            uint128 stakeAmount,
            IRewardStrategyV2.PoolData memory pool,
            uint16 lastClaimDay
        ) = (
                calculationData.staker,
                calculationData.stake.stakeDay,
                calculationData.stake.unstakeDay,
                calculationData.stake.amount,
                calculationData.pool,
                calculationData.lastClaimDay
            );
        if (
            // 1. Staker is not whitelisted.
            !_whiteListedStakersSet.contains(staker) ||
            lastClaimDay > 0 || // 2. Not claimed yet.
            pool.weight == 0 || // 3. Pool has it's weight calculated.
            stakeDay > (pool.startDay + gracePeriod) || // 4. Staked within grace period.
            // 5. Unstaked before the pool end day.
            (unstakeDay > 0 && unstakeDay <= pool.endDay)
        ) {
            return 0;
        }

        uint256 userWeight = stakeAmount * 90;

        return (userWeight * pool.reward) / pool.weight;
    }
}
