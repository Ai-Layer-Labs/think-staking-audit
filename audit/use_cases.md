# Token Staking System: Use Cases

## Overview

This document defines use cases for the Token Staking System, including both the core staking subsystem and the reward management system.

## System Components

### Core Staking System

- **StakingVault.sol**: Business logic and user interface contract
- **StakingStorage.sol**: Data persistence and historical tracking contract
- **Token.sol**: Simple ERC20 test token

### Reward Management System

- **RewardManager.sol**: Central reward calculation and distribution orchestration
- **PoolManager.sol**: Epoch lifecycle management (announced → active → ended → calculated)
- **StrategiesRegistry.sol**: Reward strategy registration and management
- **RewardBookkeeper.sol**: Reward grant tracking and claiming state management
- **Strategy Implementations**: LinearAPRStrategy, EpochPoolStrategy for different reward models

## User Use Cases

### UC1: Direct Token Staking

**Actor**: Regular User  
**Description**: User stakes their tokens with a specified time lock period  
**Contracts**: StakingVault, StakingStorage

**Preconditions**:

- User has sufficient token balance
- User has approved StakingVault to spend their tokens
- Contract is not paused
- Amount is greater than zero
- Time lock is valid (uint16, can be 0 for no lock)

**Flow**:

1. User calls `StakingVault.stake(uint128 amount, uint16 daysLock)`
2. Vault validates parameters and transfers tokens from user
3. Vault generates unique stake ID using compound key: `bytes32((uint256(uint160(staker)) << 96) | stakesCounter)`
4. Vault calls `StakingStorage.createStake(staker, amount, daysLock, flags)`
5. Storage creates stake record and updates checkpoints

**Postconditions**:

- User's tokens are transferred to StakingVault
- Stake is recorded in StakingStorage with unique stake ID
- User's `stakesCount` is incremented
- User's `totalStaked` amount is updated
- Global total staked amount is updated
- Checkpoint is created for historical tracking
- Daily snapshot is updated
- `Staked` event is emitted from both contracts

### UC2: Stake Unstaking

**Actor**: Regular User  
**Description**: User unstakes their matured tokens and receives them back  
**Contracts**: StakingVault, StakingStorage

**Preconditions**:

- User has an active stake with the specified stake ID
- Current day >= stake day + days lock (`_getCurrentDay() >= matureDay`)
- Contract is not paused
- Stake hasn't been previously unstaked (`unstakeDay == 0`)

**Flow**:

1. User calls `StakingVault.unstake(bytes32 stakeId)`
2. Vault retrieves stake via `StakingStorage.getStake(msg.sender, stakeId)`. Stake ownership is implicitly validated here; if `msg.sender` is not the owner, the stake will not be found.
3. Vault validates stake maturity
4. Vault calls `StakingStorage.removeStake(msg.sender, stakeId)`
5. Storage marks stake as unstaked (sets `unstakeDay`) and updates balances
6. Vault transfers tokens back to user

**Postconditions**:

- Stake is marked as unstaked in StakingStorage (`unstakeDay` set)
- User's `stakesCount` is decremented
- User's `totalStaked` amount is updated
- Global total staked amount is updated
- Checkpoint is created with reduced balance
- Daily snapshot is updated
- Tokens are transferred back to user
- `Unstaked` event is emitted from both contracts

### UC3: Query Active Stakes

**Actor**: Any User  
**Description**: Query active stakes and balance information  
**Contracts**: StakingStorage

**Available Queries**:

- `getStake(bytes32 stakeId)`: Get specific stake details
- `isActiveStake(address staker, bytes32 stakeId)`: Check if stake is active
- `getStakerInfo(address staker)`: Get staker summary information
- `getStakerBalance(address staker)`: Get current total staked balance
- `getStakerBalanceAt(address staker, uint16 targetDay)`: Historical balance query

**Postconditions**:

- Returns accurate stake and balance information
- No state changes

### UC20: Stake Flag System Operations

**Actor**: System  
**Description**: Manage stake flags for tracking properties and origins  
**Contracts**: StakingStorage, Flags library

**Available Operations**:

- Flag validation using `Flags.isSet(flags, bit)` for stake properties
- Origin tracking via IS_FROM_CLAIM_BIT for reward eligibility
- Flag-based filtering for analytics and reward calculations
- Extensible design supports future flag additions

**Postconditions**:

- Stake origins are accurately tracked for reward distribution
- Flag queries return correct boolean values for business logic
- System supports extensible stake property management

## Manager Role Use Cases

### UC4: Pause System

**Actor**: Manager (MANAGER_ROLE)  
**Description**: Manager pauses the staking system for emergency or maintenance  
**Contract**: StakingVault

**Preconditions**:

- Actor has MANAGER_ROLE
- System is not already paused

**Flow**:

1. Manager calls `StakingVault.pause()`
2. Contract state is set to paused

**Postconditions**:

- System is paused
- All stake/unstake operations are blocked
- `Paused` event is emitted

### UC5: Unpause System

**Actor**: Manager (MANAGER_ROLE)  
**Description**: Manager resumes normal system operations  
**Contract**: StakingVault

**Preconditions**:

- Actor has MANAGER_ROLE
- System is currently paused

**Flow**:

1. Manager calls `StakingVault.unpause()`
2. Contract state is set to unpaused

**Postconditions**:

- System is unpaused
- Stakes/unstakes can be processed again
- `Unpaused` event is emitted

## Admin Role Use Cases

### UC6: Emergency Token Recovery

**Actor**: Multisig Wallet (MULTISIG_ROLE)  
**Description**: Emergency recovery of tokens from the StakingVault contract  
**Contract**: StakingVault

**Preconditions**:

- Actor has MULTISIG_ROLE
- Contract has sufficient token balance
- Amount is greater than zero
- Destination address is valid

**Flow**:

1. Multisig calls `StakingVault.emergencyRecover(IERC20 token_, uint256 amount)`
2. Specified tokens are transferred to multisig wallet

**Postconditions**:

- Tokens are transferred to multisig wallet
- Contract balance decreases

### UC7: Role Management

**Actor**: Admin (DEFAULT_ADMIN_ROLE)  
**Description**: Grant or revoke roles for operational management  
**Contracts**: StakingVault, StakingStorage

**Available Operations**:

- Grant MANAGER_ROLE for operational functions
- Grant CLAIM_CONTRACT_ROLE for external integrations
- Grant CONTROLLER_ROLE (StakingStorage only - for StakingVault)
- Revoke any role as needed

**Postconditions**:

- Target address gains/loses specified role
- `RoleGranted`/`RoleRevoked` events are emitted

## External Integration Use Cases

### UC8: Stake from Claim Contract

**Actor**: Authorized Claiming Contract (CLAIM_CONTRACT_ROLE)  
**Description**: External claiming contract stakes tokens on behalf of a user  
**Contracts**: StakingVault, StakingStorage

**Preconditions**:

- Actor has CLAIM_CONTRACT_ROLE
- Contract is not paused
- Tokens have been transferred to vault prior to call (by claiming contract)
- Amount is greater than zero
- Staker address is valid

**Flow**:

1. Claiming contract transfers tokens to StakingVault
2. Claiming contract calls `StakingVault.stakeFromClaim(address staker, uint128 amount, uint16 daysLock)`
3. Vault generates unique stake ID for the staker
4. Vault calls `StakingStorage.createStake(staker, stakeId, amount, daysLock, true)`
5. Storage creates stake marked as from claim (`isFromClaim = true`)

**Postconditions**:

- Stake is created for the specified staker
- Stake is marked as originating from claim (`isFromClaim = true`)
- All balance tracking and checkpoints are updated
- Stake ID is returned to calling contract
- `Staked` event is emitted

## Historical Data and Analytics Use Cases

### UC9: Historical Balance Queries

**Actor**: External Analytics System  
**Description**: Query historical staking data for analytics or reward calculations  
**Contract**: StakingStorage

**Available Queries**:

- `getStakerBalanceAt(address staker, uint16 targetDay)`: Historical balance with binary search
- `batchGetStakerBalances(address[] stakers, uint16 targetDay)`: Batch historical queries
- `getDailySnapshot(uint16 day)`: Global statistics for specific day
- `getCurrentTotalStaked()`: Real-time total staked amount

**Features**:

- Binary search optimization for O(log n) historical queries
- Checkpoint system maintains complete historical record
- Batch operations for efficient multi-user queries

**Postconditions**:

- Returns accurate historical data
- No state changes

### UC10: Staker Enumeration

**Actor**: External System  
**Description**: Enumerate all stakers for batch operations or analytics  
**Contract**: StakingStorage

**Available Functions**:

- `getStakersPaginated(uint256 offset, uint256 limit)`: Paginated staker list
- `getTotalStakersCount()`: Total number of unique stakers

**Postconditions**:

- Returns paginated list of staker addresses
- No state changes

## Reward System Use Cases

### UC21: Reward Strategy Management

**Actor**: Manager (MANAGER_ROLE)
**Description**: Register and manage reward calculation strategies.
**Contract**: StrategiesRegistry

**Available Operations**:
- Register new strategies (`registerStrategy()`).
- Remove strategies (`removeStrategy()`).

**Strategy Types**:
- **`ADMIN_GRANTED`**: For pool-based rewards calculated by an off-chain process.
- **`USER_CLAIMABLE`**: For rewards that can be calculated and claimed on-demand by the user.

**Postconditions**:
- Strategies are properly registered and mapped to an ID.
- Access control prevents unauthorized modifications.

### UC22: Pool Lifecycle Management

**Actor**: Manager (MANAGER_ROLE)
**Description**: Manage reward pool states from announcement to finalization.
**Contract**: PoolManager

**Pool Flow**:
1.  **ANNOUNCED**: `upsertPool()` is called with a `strategyId` and start/end days.
2.  **ACTIVE**: `updatePoolState()` is called (typically by a keeper) when the current day is within the pool's range.
3.  **ENDED**: `updatePoolState()` is called when the current day is past the pool's `endDay`.
4.  **CALCULATED**: `finalizePool()` is called by a manager after off-chain calculations are complete, storing the `totalStakeWeight`.

**Postconditions**:
- Pools progress through a proper state machine.
- Finalized pools have the necessary data for reward granting.

### UC23: Immediate Reward Claiming

**Actor**: User
**Description**: Claim rewards from a `USER_CLAIMABLE` (e.g., APR-style) strategy.
**Contract**: RewardManager

**Flow**:
1. User calls `claimImmediateReward(strategyId, stakeId)`.
2. `RewardManager` calculates the reward based on the number of full, completed days since the user's last claim for that stake and strategy.
3. `RewardManager` validates funding, transfers the reward tokens to the user, and updates the `lastClaimDay` for that stake and strategy.

**Postconditions**:
- User receives the calculated reward tokens.
- The claim is recorded to prevent double-payment for the same period.

### UC24: Granted Reward Claiming

**Actor**: User
**Description**: Claim rewards from an `ADMIN_GRANTED` (pool-based) strategy.
**Contract**: RewardManager

**Preconditions**:
- An off-chain administrative process has already calculated the rewards for an `ENDED` pool.
- The admin process has called `RewardBookkeeper.grantReward()` to record the user's specific reward amount.

**Flow**:
1. User calls `claimGrantedRewards()`.
2. `RewardManager` queries the `RewardBookkeeper` for all of the user's unclaimed rewards.
3. `RewardManager` transfers the total reward amount to the user.
4. `RewardManager` calls `RewardBookkeeper.batchMarkClaimed()` to mark the rewards as paid.

**Postconditions**:
- User receives all their available granted rewards.
- The ledger in `RewardBookkeeper` is updated to prevent double-payment.

### UC25: Immediate Reward Restaking

**Actor**: User
**Description**: Claim rewards from a `USER_CLAIMABLE` strategy and restake them in a single transaction.
**Contract**: RewardManager, StakingVault

**Flow**:
1. User calls `claimImmediateAndRestake(strategyId, stakeId, daysLock)`.
2. `RewardManager` calculates the user's immediate reward.
3. `RewardManager` transfers the reward tokens directly to the `StakingVault`.
4. `RewardManager` calls `StakingVault.stakeFromClaim()` on behalf of the user, creating a new stake with the rewarded tokens.

**Postconditions**:
- A new stake is created in the user's name with the rewarded amount.
- The user's claim is recorded to prevent double-payment.
- The new stake is marked with the `IS_FROM_CLAIM` flag.

## Error Handling Use Cases

### UC27: Immature Stake Unstaking

**Actor**: System  
**Description**: Reject unstaking attempts before time lock expires

**Preconditions**:

- User attempts to unstake with current day < stake day + days lock

**Flow**:

1. User calls `unstake(stakeId)`
2. Vault calculates `matureDay = stakeDay + daysLock`
3. Vault checks `currentDay >= matureDay`
4. Validation fails

**Postconditions**:

- Transaction reverts with `StakeNotMatured(stakeId, matureDay, currentDay)` error
- No tokens are transferred
- No state is modified

### UC28: Invalid Stake Operations

**Actor**: System  
**Description**: Handle various invalid stake operations

**Error Scenarios**:

- **Non-existent Stake**: `StakeNotFound(staker, stakeId)`
- **Already Unstaked**: `StakeAlreadyUnstaked(stakeId)`
- **Not Stake Owner**: `NotStakeOwner(caller, owner)`
- **Invalid Amount**: `InvalidAmount()` (zero amount staking)

**Postconditions**:

- Transaction reverts with specific error
- No tokens are transferred
- No state is modified

### UC29: Paused System Operations

**Actor**: System  
**Description**: Reject stake/unstake operations when system is paused

**Preconditions**:

- User attempts stake/unstake while system is paused

**Postconditions**:

- Transaction reverts with Pausable error
- No tokens are transferred
- No state is modified

## Security Validation Use Cases

### UC30: Access Control Enforcement

**Actor**: System  
**Description**: Ensure only authorized roles can perform restricted operations

**Validations**:

- Only MANAGER_ROLE can pause/unpause
- Only DEFAULT_ADMIN_ROLE can emergency recover
- Only CLAIM_CONTRACT_ROLE can stake from claim
- Only CONTROLLER_ROLE can modify storage state

**Postconditions**:

- Unauthorized operations revert with access control error
- Authorized operations proceed normally

### UC31: Reentrancy Protection

**Actor**: System  
**Description**: Prevent reentrancy attacks during external token calls

**Protection**:

- All state-changing functions use `nonReentrant` modifier
- State changes occur before external calls
- ReentrancyGuard prevents recursive calls

**Postconditions**:

- Reentrancy attempts are blocked
- System state remains consistent

## Data Integrity Use Cases

### UC32: Checkpoint System Integrity

**Actor**: System  
**Description**: Ensure checkpoint system maintains accurate historical data

**Requirements**:

- Checkpoints created on every balance change
- Binary search maintains sorted order
- Historical queries return accurate data
- Balance calculations are consistent

**Postconditions**:

- Historical data is accurate and immutable
- Queries are efficient (O(log n))
- Data integrity is maintained

### UC33: Global Statistics Accuracy

**Actor**: System  
**Description**: Ensure global statistics remain accurate across all operations

**Tracking**:

- `currentTotalStaked` updated on stake/unstake
- Daily snapshots track historical totals
- Staker count and registration maintained

**Postconditions**:

- Global totals match sum of individual stakes
- Historical snapshots are accurate
- Statistics remain consistent

## Integration Requirements

### UC34: Token Integration

**Actor**: System  
**Description**: Ensure proper ERC20 token integration

**Requirements**:

- SafeERC20 for all token operations
- Proper allowance and balance checks
- Immutable token reference prevents switching

**Postconditions**:

- Token operations are secure
- Balance checks are accurate
- No token-related vulnerabilities

### UC35: Storage-Vault Integration

**Actor**: System  
**Description**: Ensure proper integration between StakingVault and StakingStorage

**Requirements**:

- Only vault can modify storage (CONTROLLER_ROLE)
- Coordinated event emission
- Consistent data validation

**Postconditions**:

- Data integrity across contracts
- Proper access control enforcement
- Coordinated state changes
