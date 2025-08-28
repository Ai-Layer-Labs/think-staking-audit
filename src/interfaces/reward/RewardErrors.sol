// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract RewardErrors {
    error ControllerAlreadySet();
    error InvalidAddress();
    error InvalidInputArrays();

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

    // --- PooldManager Errors ---
    error PoolDoesNotExist(uint256 poolId);
    error PoolNotSetUp(uint256 poolId);
    error PoolNotFullyFunded(uint256 poolId);
    error PoolNotInitializedOrCalculated(uint256 poolId);
    error PoolAlreadyActiveOrFinalized(uint256 poolId);
    error PoolNotDeclared(uint256 poolId);
    error InvalidPoolDates();
    error PoolNotEnded(uint256 poolId);
    error PoolAlreadyCalculated(uint256 poolId);
    error UserNotEligibleForPool();
    error TotalEligibleWeightIsZero();
    error PoolHasAlreadyBeenAnnounced();
    error PoolNotStarted(uint256 poolId);

    // --- Stacking Policy Errors ---
    error LayerIsLocked(uint256 layer, uint16 day);

    // --- Strategy Errors ---
    error StrategyExist(uint256 strategyId);
    error StrategyNotExist(uint256 strategyId);
    error StrategyNotPreFunded(uint256 strategyId);
    error StrategyCannotBeChanged();
    error AmountMustBeGreaterThanZero();
    error InsufficientStrategyBalance();
    error CallerIsNotManager();

    // --- ClaimsJournal Errors ---
    error LayerAlreadyHasClaim(uint256 layer, uint16 day);
    error LayerAlreadyHasSemiExclusiveClaim(uint256 layer, uint16 day);
    error LayerAlreadyHasExclusiveClaim(uint256 layer, uint16 day);
}
