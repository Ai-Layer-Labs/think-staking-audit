// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract RewardErrors {
    error ControllerAlreadySet();

    // --- RewardManager Errors ---
    error DeclaredRewardZero();
    error DeclaredAmountLessThanDeposited(uint256 declared, uint256 deposited);
    error DepositAmountZero();
    error DepositExceedsDeclared(uint256 total, uint256 declared);
    error NotStakeOwner(address sender, address owner);
    error NoRewardToRestake();
    error NoRewardToClaim();
    error RewardAlreadyGranted();
    error InsufficientDepositedFunds(uint256 requested, uint256 available);
    error RewardAlreadyClaimed(uint256 rewardIndex);

    // --- PooldManager Errors ---
    error PoolDoesNotExist(uint32 poolId);
    error PoolNotSetUp(uint32 poolId);
    error PoolNotFullyFunded(uint32 poolId);
    error PoolNotInitializedOrCalculated(uint32 poolId);
    error PoolAlreadyActiveOrFinalized(uint32 poolId);
    error PoolNotDeclared(uint32 poolId);
    error InvalidPoolDates();
    error PoolNotEnded(uint32 poolId);
    error PoolAlreadyCalculated(uint32 poolId);
    error UserNotEligibleForPool();
    error TotalEligibleWeightIsZero();

    // --- Stacking Policy Errors ---
    error LayerIsLocked(uint8 layer, uint256 day);

    // --- Strategy Errors ---
    error StrategyExist(uint32 strategyId);
    error StrategyNotPreFunded(uint32 strategyId);
    error StrategyNotRegistered(uint32 strategyId);
    error StrategyCannotBeChanged();
}
