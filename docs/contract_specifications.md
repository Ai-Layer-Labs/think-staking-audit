# Token Staking System: Contract Specifications

This document provides comprehensive technical specifications for the Token staking system contracts, including all functions, events, errors, and data structures.

## RewardManager.sol

### State Variables

- `MANAGER_ROLE`: `bytes32` - Role for pausing/unpausing the contract and funding strategies.
- `stakingStorage`: `IStakingStorage` - Immutable reference to the storage contract.
- `strategiesRegistry`: `StrategiesRegistry` - Immutable reference to the strategy registry.
- `rewardBookkeeper`: `RewardBookkeeper` - Immutable reference to the ledger for granted rewards.
- `stakingVault`: `IStakingVault` - Immutable reference to the staking vault for restaking.
- `strategyBalances`: `mapping(bytes32 => uint256)` - Balances for `PRE_FUNDED` immediate strategies.
- `lastClaimDay`: `mapping(bytes32 => mapping(bytes32 => uint256))` - Tracks the last claim day for a user's stake and a specific immediate strategy.
- `exclusiveClaimDay`: `mapping(bytes32 => mapping(uint8 => uint256))` - Tracks the last claim day for a user's stake within an exclusive reward layer.

### Functions

- `depositForStrategy(uint16 _strategyId, uint256 _amount)`: Deposits funds for a `PRE_FUNDED` immediate strategy. Access: `MANAGER_ROLE`.
- `claimImmediateReward(uint16 _strategyId, bytes32 _stakeId) returns (uint256)`: Claims rewards for a `USER_CLAIMABLE` (immediate) strategy.
- `claimGrantedRewards()`: Claims all available rewards from `ADMIN_GRANTED` (pool-based) strategies that have been recorded in the `RewardBookkeeper`.
- `claimImmediateAndRestake(uint16 _strategyId, bytes32 _stakeId, uint16 _daysLock)`: Claims rewards from an immediate strategy and restakes them in a single transaction.
- `pause()`: Pauses the contract. Access: `MANAGER_ROLE`.
- `unpause()`: Unpauses the contract. Access: `MANAGER_ROLE`.

### Events

- `ImmediateRewardClaimed(address indexed user, bytes32 indexed strategyId, bytes32 indexed stakeId, uint256 amount, uint256 fromDay, uint256 toDay)`
- `GrantedRewardsClaimed(address indexed user, uint256 totalAmount, uint256 rewardCount)`
- `StrategyFunded(bytes32 indexed strategyId, uint256 amount)`

---

## StakingVault.sol

### State Variables

- `MANAGER_ROLE`: `bytes32` - Role for pausing/unpausing the contract.
- `CLAIM_CONTRACT_ROLE`: `bytes32` - Role for integrated claim contracts.
- `MULTISIG_ROLE`: `bytes32` - Dedicated role for emergency token recovery.
- `stakingStorage`: `IStakingStorage` - Immutable reference to the storage contract.
- `token`: `IERC20` - Immutable reference to the staking token.

### Functions

- `stake(uint128 amount, uint16 daysLock) returns (bytes32 stakeId)`: Stakes tokens for the caller.
- `unstake(bytes32 stakeId)`: Unstakes matured tokens for the caller.
- `stakeFromClaim(address staker, uint128 amount, uint16 daysLock) returns (bytes32 stakeId)`: Stakes tokens on behalf of a user from an authorized claim contract.
- `pause()`: Pauses the contract. Access: `MANAGER_ROLE`.
- `unpause()`: Unpauses the contract. Access: `MANAGER_ROLE`.
- `emergencyRecover(IERC20 token_, uint256 amount)`: Recovers non-staking ERC20 tokens. Access: `MULTISIG_ROLE`.

### Events

- `Staked(address indexed staker, bytes32 stakeId, uint128 amount, uint16 indexed stakeDay, uint16 indexed daysLock)`
- `Unstaked(address indexed staker, bytes32 indexed stakeId, uint16 indexed unstakeDay, uint128 amount)`
- `EmergencyRecover(address token, address to, uint256 amount)`

### Custom Errors

- `InvalidAmount()`
- `StakeNotFound(address staker, bytes32 stakeId)`
- `StakeNotMatured(bytes32 stakeId, uint16 matureDay, uint16 currentDay)`
- `StakeAlreadyUnstaked(bytes32 stakeId)`
- `NotStakeOwner(address caller, address owner)`

---

## StakingStorage.sol

### State Variables

- `MANAGER_ROLE`: `bytes32` - Role for future administrative functions.
- `CONTROLLER_ROLE`: `bytes32` - Role required to modify storage state; granted to `StakingVault`.
- `_stakes`: `mapping(bytes32 => Stake)`
- `_stakers`: `mapping(address => StakerInfo)`
- `_stakerCheckpoints`: `mapping(address => uint16[])`
- `_stakerBalances`: `mapping(address => mapping(uint16 => uint128))`
- `_dailySnapshots`: `mapping(uint16 => DailySnapshot)`
- `_allStakers`: `EnumerableSet.AddressSet`

### Data Structures

- `Stake { uint128 amount, uint16 stakeDay, uint16 unstakeDay, uint16 daysLock, uint16 flags }`
- `StakerInfo { uint128 totalStaked, uint128 totalRewarded, uint128 totalClaimed, uint16 stakesCounter, uint16 activeStakesNumber, uint16 lastCheckpointDay }`
- `DailySnapshot { uint128 totalStakedAmount, uint16 totalStakesCount }`

### Functions

- `createStake(address staker, uint128 amount, uint16 daysLock, uint16 flags)`: Creates a new stake record. Access: `CONTROLLER_ROLE`.
- `removeStake(address staker, bytes32 id)`: Marks a stake as unstaked. Access: `CONTROLLER_ROLE`.
- `getStake(bytes32 id) returns (Stake memory)`: Retrieves a specific stake.
- `getStakerInfo(address staker) returns (StakerInfo memory)`: Retrieves information about a staker.
- `getStakerBalanceAt(address staker, uint16 targetDay) returns (uint128)`: Retrieves a staker's historical balance using binary search.
- `getStakersPaginated(uint256 offset, uint256 limit) returns (address[] memory)`: Returns a paginated list of all unique stakers.
- `getTotalStakersCount() returns (uint256)`: Returns the total number of unique stakers.
- `getCurrentTotalStaked() returns (uint128)`: Returns the total amount of tokens currently staked in the system.
- `getDailySnapshot(uint16 day) returns (DailySnapshot memory)`: Returns the daily snapshot for a given day.

### Events

- `Staked(address indexed staker, bytes32 indexed stakeId, uint128 amount, uint16 indexed stakeDay, uint16 daysLock, uint16 flags)`
- `Unstaked(address indexed staker, bytes32 indexed stakeId, uint16 indexed unstakeDay, uint128 amount)`
- `CheckpointCreated(address indexed staker, uint16 indexed day, uint128 balance, uint16 stakesCount)`

---

_For interfaces, see `src/interfaces/`._
_For gas costs and security analysis, see the [System Architecture](audit/system_architecture.md) document._
