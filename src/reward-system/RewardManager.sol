// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../interfaces/staking/IStakingStorage.sol";
import "../interfaces/reward/IRewardStrategy.sol";

import "./ClaimsJournal.sol";
import "./PoolManager.sol";
import "./FundingManager.sol";

import "../interfaces/reward/RewardErrors.sol";

/**
 * @title RewardManager
 * @author @Tudmotu & Gemini
 * @notice A stateless orchestrator for all reward claims, inheriting funding logic.
 * @dev This contract holds no state about users' claims. It reads from storage contracts,
 *      executes business logic from strategy contracts, and coordinates payments and state updates.
 */
contract RewardManager is
    FundingManager,
    Pausable,
    RewardErrors,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // --- Immutable contract dependencies ---
    IStakingStorage public immutable stakingStorage;
    ClaimsJournal public claimsJournal;
    PoolManager public immutable poolManager;

    event RewardClaimed(
        address indexed user,
        bytes32 stakeId,
        uint256 indexed poolId,
        uint32 indexed strategyId,
        uint256 rewardAmount,
        uint16 claimDay
    );

    constructor(
        address _admin,
        address _manager,
        IStakingStorage _stakingStorage,
        StrategiesRegistry _strategiesRegistry,
        ClaimsJournal _claimsJournal,
        PoolManager _poolManager
    ) FundingManager(_admin, _manager, _strategiesRegistry) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MANAGER_ROLE, _manager);

        stakingStorage = _stakingStorage;
        claimsJournal = _claimsJournal;
        poolManager = _poolManager;
    }

    function setClaimsJournal(
        ClaimsJournal _newClaimsJournal
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        claimsJournal = _newClaimsJournal;
    }

    function pause() external onlyRole(MANAGER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(MANAGER_ROLE) {
        _unpause();
    }

    // ===================================================================
    //                      USER CLAIM FUNCTIONS
    // ===================================================================
    function claimReward(
        bytes32 stakeId,
        uint32 poolId,
        uint32 strategyId
    ) external nonReentrant whenNotPaused {
        // --- 1. Validation & Data Fetching ---
        (
            address staker,
            address strategyAddress,
            uint8 layerId
        ) = _validateAndGetData(stakeId, poolId, strategyId);

        // --- 2. Reward Calculation ---
        uint256 rewardAmount = _calculateReward(
            staker,
            stakeId,
            poolId,
            strategyId,
            strategyAddress
        );
        require(rewardAmount > 0, "No reward to claim");

        // --- 3. Payout ---
        _payout(staker, strategyId, strategyAddress, rewardAmount);

        // --- 4. Record Keeping ---
        _recordClaim(staker, poolId, strategyId, layerId, stakeId);

        // --- 5. Emit Event ---
        emit RewardClaimed(
            staker,
            stakeId,
            poolId,
            strategyId,
            rewardAmount,
            _getCurrentDay()
        );
    }

    // ===================================================================
    //                      Internal Functions
    // ===================================================================

    function _validateAndGetData(
        bytes32 stakeId,
        uint32 poolId,
        uint32 strategyId
    )
        internal
        view
        returns (address staker, address strategyAddress, uint8 layerId)
    {
        staker = _getStakerFromId(stakeId);
        require(staker == _msgSender(), "Not stake owner");

        strategyAddress = strategiesRegistry.getStrategyAddress(strategyId);
        require(strategyAddress != address(0), "Strategy not registered");

        layerId = poolManager.getStrategyLayer(poolId, strategyId);
        _validateExclusivity(staker, poolId, layerId, strategyId);

        // Strategy-dependent validation
        IRewardStrategy.StrategyType strategyType = IRewardStrategy(
            strategyAddress
        ).getStrategyType();

        if (strategyType == IRewardStrategy.StrategyType.POOL_SIZE_DEPENDENT) {
            require(poolManager.isPoolEnded(poolId), "Pool has not ended");
        } else {
            require(poolManager.isPoolActive(poolId), "Pool is not active");
        }
    }

    function _validateExclusivity(
        address staker,
        uint32 poolId,
        uint8 layerId,
        uint32 strategyId
    ) internal view {
        PoolManager.StrategyExclusivity strategyType = poolManager
            .getStrategyExclusivity(strategyId);
        ClaimsJournal.LayerClaimType layerClaimState = claimsJournal
            .getLayerClaimState(staker, poolId, layerId);

        if (strategyType == PoolManager.StrategyExclusivity.EXCLUSIVE) {
            require(
                layerClaimState == ClaimsJournal.LayerClaimType.NONE,
                "Layer has claims"
            );
        } else {
            require(
                layerClaimState != ClaimsJournal.LayerClaimType.EXCLUSIVE,
                "Layer locked by exclusive claim"
            );
            if (
                strategyType == PoolManager.StrategyExclusivity.SEMI_EXCLUSIVE
            ) {
                require(
                    layerClaimState !=
                        ClaimsJournal.LayerClaimType.SEMI_EXCLUSIVE,
                    "Layer has semi-exclusive claim"
                );
            }
        }
    }

    function _calculateReward(
        address staker,
        bytes32 stakeId,
        uint32 poolId,
        uint32 strategyId,
        address strategyAddress
    ) internal view returns (uint256 rewardAmount) {
        IRewardStrategy strategyContract = IRewardStrategy(strategyAddress);
        IRewardStrategy.StrategyType strategyType = strategyContract
            .getStrategyType();
        IStakingStorage.Stake memory stake = stakingStorage.getStake(stakeId);
        PoolManager.Pool memory pool = poolManager.getPool(poolId);

        uint16 lastClaimDay = claimsJournal.getLastClaimDay(
            stakeId,
            strategyId
        );

        if (strategyType == IRewardStrategy.StrategyType.POOL_SIZE_DEPENDENT) {
            // CRITICAL: Prevent re-claiming a one-time reward.
            require(lastClaimDay == 0, "Reward already claimed");
            require(
                poolManager.isPoolCalculated(poolId),
                "Pool not calculated"
            );

            rewardAmount = strategyContract.calculateReward(
                staker,
                stake,
                pool.totalPoolWeight,
                strategyBalances[strategyId],
                pool.startDay,
                pool.endDay
            );
        } else if (
            strategyType == IRewardStrategy.StrategyType.POOL_SIZE_INDEPENDENT
        ) {
            // For this type, lastClaimDay is a checkpoint, not a blocker.
            rewardAmount = strategyContract.calculateReward(
                staker,
                stake,
                pool.startDay,
                pool.endDay,
                lastClaimDay
            );
        }
    }
    function _payout(
        address staker,
        uint32 strategyId,
        address strategyAddress,
        uint256 rewardAmount
    ) internal {
        _decreaseStrategyBalance(strategyId, rewardAmount);

        address rewardToken = IRewardStrategy(strategyAddress).getRewardToken();
        IERC20(rewardToken).safeTransfer(staker, rewardAmount);
    }

    function _recordClaim(
        address staker,
        uint32 poolId,
        uint32 strategyId,
        uint8 layerId,
        bytes32 stakeId
    ) internal {
        PoolManager.StrategyExclusivity strategyType = poolManager
            .getStrategyExclusivity(strategyId);

        IRewardStrategy strategyContract = IRewardStrategy(
            strategiesRegistry.getStrategyAddress(strategyId)
        );
        bool isPoolSizeDependent = strategyContract.getStrategyType() ==
            IRewardStrategy.StrategyType.POOL_SIZE_DEPENDENT;

        ClaimsJournal.LayerClaimType claimType;
        if (strategyType == PoolManager.StrategyExclusivity.NORMAL) {
            claimType = ClaimsJournal.LayerClaimType.NORMAL;
        } else if (
            strategyType == PoolManager.StrategyExclusivity.SEMI_EXCLUSIVE
        ) {
            claimType = ClaimsJournal.LayerClaimType.SEMI_EXCLUSIVE;
        } else {
            claimType = ClaimsJournal.LayerClaimType.EXCLUSIVE;
        }

        claimsJournal.recordClaim(
            staker,
            poolId,
            layerId,
            strategyId,
            stakeId,
            claimType,
            isPoolSizeDependent,
            _getCurrentDay()
        );
    }

    function _getStakerFromId(bytes32 stakeId) internal pure returns (address) {
        return address(uint160(uint256(stakeId) >> 96));
    }

    function _getCurrentDay() internal view returns (uint16) {
        return uint16(block.timestamp / 1 days);
    }
}
