// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/staking/IStakingStorage.sol";
import "../interfaces/staking/IStakingVault.sol";
import "../interfaces/reward/IRewardStrategy.sol";
import "../interfaces/reward/IRewardManager.sol";
import "./RewardBookkeeper.sol";
import "./StrategiesRegistry.sol";
import "../interfaces/reward/RewardErrors.sol";

/**
 * @title RewardManager
 * @author @Tudmotu
 * @notice A refactored, central orchestrator for reward claims and funding.
 * @dev Supports two distinct reward models:
 *      1. ADMIN_GRANTED: Claims rewards from a RewardBookkeeper acting as a ledger.
 *      2. USER_CLAIMABLE: Calculates and pays rewards on-demand for immediate strategies.
 */
contract RewardManager is
    IRewardManager,
    IRewardStrategy,
    AccessControl,
    Pausable,
    RewardErrors
{
    using SafeERC20 for IERC20;

    struct RewardCalculationData {
        IRewardStrategy strategy;
        IStakingStorage.Stake stake;
        uint256 effectiveStartDay;
        uint8 rewardLayer;
        IRewardStrategy.Policy stackingPolicy;
        address rewardToken;
    }

    struct ClaimableRewardInfo {
        uint16 strategyId;
        uint32 poolId;
        uint8 rewardLayer;
        IRewardStrategy.Policy stackingPolicy;
        uint256 amount;
        bool isPermanentlyClaimed; // Is this reward (or a conflicting one) already locked forever?
    }

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    IStakingStorage public immutable stakingStorage;
    StrategiesRegistry public immutable strategiesRegistry;
    RewardBookkeeper public immutable rewardBookkeeper;
    IStakingVault public immutable stakingVault;

    // For PRE_FUNDED strategies
    mapping(uint32 => uint256) public strategyBalances; // strategyId -> balance

    mapping(bytes32 stakeId => mapping(uint32 strategyId => uint256 day))
        public lastClaimDay;

    constructor(
        address _admin,
        address _manager,
        IStakingStorage _stakingStorage,
        StrategiesRegistry _strategiesRegistry,
        RewardBookkeeper _rewardBookkeeper,
        IStakingVault _stakingVault
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MANAGER_ROLE, _manager);
        stakingStorage = _stakingStorage;
        strategiesRegistry = _strategiesRegistry;
        rewardBookkeeper = _rewardBookkeeper;
        stakingVault = _stakingVault;
    }

    function pause() external onlyRole(MANAGER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(MANAGER_ROLE) {
        _unpause();
    }

    // ═══════════════════════════════════════════════════════════════════
    //                        FUNDING FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    function depositForStrategy(
        uint32 _strategyId,
        uint256 _amount
    ) external onlyRole(MANAGER_ROLE) {
        address strategyAddress = strategiesRegistry.getStrategyAddress(
            _strategyId
        );
        require(
            strategyAddress != address(0),
            RewardErrors.StrategyNotRegistered(_strategyId)
        );

        IRewardStrategy strategy = IRewardStrategy(strategyAddress);
        (, address rewardToken, , , ) = strategy.getParameters();

        require(_amount > 0, RewardErrors.DeclaredRewardZero());

        strategyBalances[_strategyId] += _amount;
        IERC20(rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        emit StrategyFunded(_strategyId, _amount);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                        CLAIM FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    function claimImmediateReward(
        uint32 _strategyId,
        bytes32 _stakeId
    ) public whenNotPaused returns (uint256) {
        uint256 rewardAmount = _calculateAndValidateImmediateReward(
            msg.sender,
            _strategyId,
            _stakeId
        );
        require(rewardAmount > 0, RewardErrors.NoRewardToClaim());

        address strategyAddress = strategiesRegistry.getStrategyAddress(
            _strategyId
        );
        IRewardStrategy strategy = IRewardStrategy(strategyAddress);
        (, address rewardToken, , , ) = strategy.getParameters();

        // For PRE_FUNDED, check balance. For others, assume contract has funds.
        if (strategyBalances[_strategyId] > 0) {
            require(
                strategyBalances[_strategyId] >= rewardAmount,
                RewardErrors.InsufficientDepositedFunds(
                    rewardAmount,
                    strategyBalances[_strategyId]
                )
            );

            strategyBalances[_strategyId] -= rewardAmount;
        }

        IERC20(rewardToken).safeTransfer(msg.sender, rewardAmount);

        return rewardAmount;
    }

    function claimGrantedRewards() public whenNotPaused {
        (
            RewardBookkeeper.GrantedReward[] memory rewards,
            uint256[] memory indices
        ) = rewardBookkeeper.getUserClaimableRewards(msg.sender);
        require(rewards.length > 0, RewardErrors.NoRewardToClaim());

        // This simplified version assumes a single reward token for all granted rewards in the batch.
        uint256 totalAmount;
        address rewardToken;

        // Get the token from the first reward's strategy
        uint32 firstStrategyId = rewards[0].strategyId;
        address firstStrategyAddress = strategiesRegistry.getStrategyAddress(
            firstStrategyId
        );
        require(
            firstStrategyAddress != address(0),
            RewardErrors.StrategyNotRegistered(firstStrategyId)
        );
        (, rewardToken, , , ) = IRewardStrategy(firstStrategyAddress)
            .getParameters();

        for (uint256 i = 0; i < rewards.length; i++) {
            totalAmount += rewards[i].amount;
        }

        IERC20(rewardToken).safeTransfer(msg.sender, totalAmount);

        // Mark as claimed in the bookkeeper
        rewardBookkeeper.batchMarkClaimed(msg.sender, indices);

        emit GrantedRewardsClaimed(msg.sender, totalAmount, rewards.length);
    }

    function claimImmediateAndRestake(
        uint32 _strategyId,
        bytes32 _stakeId,
        uint16 _daysLock
    ) external whenNotPaused {
        uint256 claimedAmount = _calculateAndValidateImmediateReward(
            msg.sender,
            _strategyId,
            _stakeId
        );
        require(claimedAmount > 0, RewardErrors.NoRewardToRestake());

        address strategyAddress = strategiesRegistry.getStrategyAddress(
            _strategyId
        );
        IRewardStrategy strategy = IRewardStrategy(strategyAddress);
        (, address rewardToken, , , ) = strategy.getParameters();

        // Transfer the reward to the StakingVault, so it can create the stake.
        IERC20(rewardToken).safeTransfer(address(stakingVault), claimedAmount);

        // Now call the existing stakeFromClaim function.
        stakingVault.stakeFromClaim(
            msg.sender,
            uint128(claimedAmount),
            _daysLock
        );
    }

    function claimRewards(uint32[] calldata _strategyIds) external {
        address user = msg.sender;
        uint256 totalAmountToPay = 0;
        mapping(uint8 => bool) layersWithExclusiveClaim;

        for (uint i = 0; i < _strategyIds.length; i++) {
            uint32 strategyId = _strategyIds[i];

            // Get strategy parameters
            (
                ,
                uint8 rewardLayer,
                Policy stackingPolicy,
                ClaimType claimType
            ) = strategiesRegistry.getStrategy(strategyId).getParameters();

            // Check for conflicts within this transaction
            if (
                stackingPolicy == Policy.EXCLUSIVE_IN_LAYER &&
                layersWithExclusiveClaim[rewardLayer]
            ) {
                revert(
                    "Cannot claim multiple exclusive rewards from the same layer."
                );
            }

            //   // All strategies must be associated with a Pool to provide context for the lock.
            uint32 poolId = getPoolForStrategy(strategyId);

            // Check the permanent lock
            if (stackingPolicy == Policy.EXCLUSIVE_IN_LAYER) {
                require(
                    !hasClaimedForPoolLayer[user][rewardLayer][poolId],
                    "Reward already claimed."
                );
            }

            uint256 rewardAmount = 0;
            if (claimType == ClaimType.ADMIN_GRANTED) {
                rewardAmount = rewardBookkeeper.findAndMarkClaimed(
                    user,
                    strategyId,
                    poolId
                ); // Pass poolId for precision
            } else {
                // USER_CLAIMABLE
                rewardAmount = strategiesRegistry
                    .getStrategy(strategyId)
                    .calculateReward(
                        user,
                        stake,
                        effectiveStartDay,
                        currentDay - 1
                    );
            }

            if (rewardAmount > 0) {
                totalAmountToPay += rewardAmount;

                // If exclusive, set the permanent lock and the in-transaction lock.
                if (stackingPolicy == Policy.EXCLUSIVE_IN_LAYER) {
                    hasClaimedForPoolLayer[user][rewardLayer][poolId] = true;
                    layersWithExclusiveClaim[rewardLayer] = true;
                }
            }
        }

        // Perform single payment
        if (totalAmountToPay > 0) {
            rewardToken.safeTransfer(user, totalAmountToPay);
        }
    }

    // ===================================================================
    //                        INTERNAL LOGIC
    // ===================================================================

    function _getRewardCalculationData(
        address _user,
        uint32 _strategyId,
        bytes32 _stakeId
    ) internal view returns (RewardCalculationData memory data) {
        address owner = address(uint160(uint256(_stakeId) >> 96));
        require(owner == _user, "Not stake owner");

        address strategyAddress = strategiesRegistry.getStrategyAddress(
            _strategyId
        );
        require(strategyAddress != address(0), "Strategy not registered");

        data.strategy = IRewardStrategy(strategyAddress);
        (, data.rewardToken, data.rewardLayer, data.stackingPolicy, ) = data
            .strategy
            .getParameters();

        data.stake = stakingStorage.getStake(_stakeId);
        uint256 lastClaim = lastClaimDay[_stakeId][_strategyId];
        data.effectiveStartDay = lastClaim > data.stake.stakeDay
            ? lastClaim + 1
            : data.stake.stakeDay;
    }

    function _calculateAndValidateImmediateReward(
        address _user,
        uint32 _strategyId,
        bytes32 _stakeId
    ) internal returns (uint256) {
        RewardCalculationData memory data = _getRewardCalculationData(
            _user,
            _strategyId,
            _stakeId
        );
        uint256 currentDay = block.timestamp / 1 days;

        if (data.effectiveStartDay >= currentDay) return 0;

        uint256 rewardAmount = data.strategy.calculateReward(
            _user,
            data.stake,
            data.effectiveStartDay,
            currentDay - 1 // Rewards are for completed days
        );
        if (rewardAmount == 0) return 0;

        // Enforce exclusivity and update timestamps
        if (data.stackingPolicy == IRewardStrategy.Policy.EXCLUSIVE_IN_LAYER) {
            require(
                exclusiveClaimDay[_stakeId][data.rewardLayer] != currentDay,
                "Layer is locked"
            );
            exclusiveClaimDay[_stakeId][data.rewardLayer] = currentDay;
        }
        lastClaimDay[_stakeId][_strategyId] = currentDay;

        emit ImmediateRewardClaimed(
            _user,
            _strategyId,
            _stakeId,
            rewardAmount,
            data.effectiveStartDay,
            currentDay
        );

        return rewardAmount;
    }
}
