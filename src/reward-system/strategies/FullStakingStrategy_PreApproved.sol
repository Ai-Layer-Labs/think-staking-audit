// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../../interfaces/reward/IRewardStrategyV2.sol";
import "../../interfaces/staking/IStakingStorage.sol";
import "../../lib/Cryptography.sol";

/**
 * @title FullStakingStrategy
 * @author @Tudmotu
 * @notice A strategy that rewards stakers who keep their stake for the entire duration of a parent pool.
 * @dev This is an ADMIN_GRANTED strategy. It returns the stake amount as the weight for final calculation.
 */
contract FullStakingStrategy_PreApproved is IRewardStrategyV2, Cryptography {
    address public immutable rewardToken;
    uint16 public immutable gracePeriod; // Grace period in days.
    address public immutable signer;
    error MethodNotSupported();

    constructor(address _rewardToken, uint16 _gracePeriod, address _signer) {
        rewardToken = _rewardToken;
        gracePeriod = _gracePeriod;
        signer = _signer;
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
        bytes calldata signature
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
        if (
            lastClaimDay > 0 || // 1. Not claimed yet.
            pool.weight == 0 || // 2. Pool has it's weight calculated.
            stakeDay > (pool.startDay + gracePeriod) || // 3. Staked within grace period.
            // 4. Unstaked before the pool end day.
            (unstakeDay > 0 && unstakeDay <= pool.endDay) ||
            _verifyPayload(
                signature,
                pool.weight,
                pool.startDay,
                pool.endDay,
                calculationData.staker
            )
        ) {
            return 0;
        }

        uint256 userWeight = stakeAmount * 90;

        return (userWeight * pool.reward) / pool.weight;
    }

    function _verifyPayload(
        bytes memory signature,
        uint256 totalPoolWeight,
        uint16 poolStartDay,
        uint16 poolEndDay,
        address staker
    ) private view returns (bool) {
        bytes memory payload = abi.encode(
            totalPoolWeight,
            poolStartDay,
            poolEndDay,
            staker
        );

        return Cryptography.verifySignature(signer, payload, signature);
    }
}
