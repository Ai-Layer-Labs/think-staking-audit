# Token Staking System: Test Cases

## Overview

This document defines comprehensive test cases for the **TOKEN STAKING & REWARD SYSTEM**, including both the core staking subsystem and the comprehensive reward management system. Test cases are mapped to use cases defined in `use_cases.md` and cover all contracts and integration points.

**Status**: This specification defines the complete test suite needed for audit readiness. Many tests are missing and need to be implemented.

## Test Categories Overview

- **Core Staking Tests (TC1-TC22)**: 22 practical test cases covering StakingVault and StakingStorage
- **Reward System Tests (TC_R01-TC_R30)**: 30 test cases covering complete reward functionality
- **Flag System Tests (TC_F01-TC_F03)**: 3 test cases for extensible flag operations
- **Integration Tests (TC_I01-TC_I07)**: 7 simplified test cases for cross-system integration

**Total: 62 practical test cases** _(Removed over-engineered/redundant tests)_

**Removed Categories:**

- Edge case tests (TC29-TC43) - Over-engineered implementation details
- Performance Tests - Use separate performance testing
- Invariant Tests - Covered by functional tests
- Error Recovery Tests - Redundant with error handling
- Event Tests - Events verified within functional tests
- Mathematical precision tests - Focus on business logic only

## Core Staking Function Tests

### TC1: Successful Direct Stake (UC1)

```gherkin
Feature: Direct Token Staking
  Scenario: User successfully stakes tokens with time lock
    Given the staking system is not paused
    And user has sufficient token balance (>= stake amount)
    And user has approved StakingVault to spend tokens (>= stake amount)
    And stake amount is greater than zero
    And days lock is valid uint16 value
    When user calls StakingVault.stake(amount, daysLock)
    Then tokens should be transferred from user to StakingVault
    And unique stake ID should be generated using compound key: bytes32((uint256(uint160(staker)) << 96) | stakesCounter)
    And StakingStorage.createStake should be called with correct parameters
    And stake should be recorded with isFromClaim = false
    And user's stakesCount should be incremented
    And user's totalStaked should be increased by amount
    And global currentTotalStaked should be increased by amount
    And checkpoint should be created for current day
    And daily snapshot should be updated
    And Staked event should be emitted from both contracts
    And stake ID should be returned to caller
```

### TC2: Successful Unstaking (UC2)

```gherkin
Feature: Token Unstaking
  Scenario: User successfully unstakes matured tokens
    Given user has an active stake with valid stake ID
    And current day >= stake day + days lock (time lock expired)
    And the staking system is not paused
    And stake has not been previously unstaked (unstakeDay == 0)
    When user calls StakingVault.unstake(stakeId)
    Then StakingStorage.getStake should be called to retrieve stake details
    And time lock validation should pass
    And StakingStorage.removeStake should be called
    And stake should be marked as unstaked (unstakeDay set to current day)
    And user's stakesCount should be decremented
    And user's totalStaked should be decreased by stake amount
    And global currentTotalStaked should be decreased by stake amount
    And checkpoint should be created with reduced balance
    And daily snapshot should be updated
    And tokens should be transferred back to user
    And Unstaked event should be emitted from both contracts
```

### TC3: Failed Unstaking - Stake Not Matured (UC11)

```gherkin
Feature: Time Lock Validation
  Scenario: User attempts to unstake before time lock expires
    Given user has an active stake with 30 days lock
    And only 15 days have passed since staking
    And current day < stake day + days lock
    When user attempts to unstake(stakeId)
    Then transaction should revert with StakeNotMatured error
    And error should include stakeId, matureDay, and currentDay
    And no tokens should be transferred
    And no state should be modified in either contract
```

### TC4: SafeERC20 Basic Usage Verification (UC12)

```gherkin
Feature: SafeERC20 Library Usage
  Scenario: Verify SafeERC20 is used for token operations
    Given StakingVault uses SafeERC20 for token transfers
    When token transfers occur during stake/unstake
    Then SafeERC20.transferFrom and SafeERC20.transfer should be used
    And basic token operations should complete successfully
```

### TC5: Failed Staking - Zero Amount (UC12)

```gherkin
Feature: Amount Validation
  Scenario: User attempts to stake zero tokens
    Given user calls stake with amount = 0
    When user attempts to stake(0, 10)
    Then transaction should revert with InvalidAmount error
    And no tokens should be transferred
    And no stake should be created
```

## Claim Contract Integration Tests

### TC6: Stake from Claim Contract (UC8)

```gherkin
Feature: Claim Integration
  Scenario: Claiming contract stakes on behalf of user
    Given claiming contract has CLAIM_CONTRACT_ROLE
    And the staking system is not paused
    And tokens have been transferred to StakingVault beforehand
    And staker address is valid (not zero)
    And amount is greater than zero
    When claiming contract calls stakeFromClaim(staker, amount, daysLock)
    Then unique stake ID should be generated for the staker
    And StakingStorage.createStake should be called with isFromClaim = true
    And stake should be created for specified staker (not claiming contract)
    And stake should be marked as from claim
    And staker's totals should be updated
    And global totals should be updated
    And checkpoint should be created for staker
    And Staked event should be emitted
    And stake ID should be returned to claiming contract
```

### TC7: Basic Role Verification - Claim Contract (UC14)

```gherkin
Feature: Basic Access Control
  Scenario: Verify CLAIM_CONTRACT_ROLE enforcement
    Given contract does not have CLAIM_CONTRACT_ROLE
    When contract calls stakeFromClaim(staker, amount, daysLock)
    Then transaction should revert with AccessControl error
```

## Manager Role Tests

### TC8: Basic Pausable Usage (UC4)

```gherkin
Feature: Pausable Library Usage
  Scenario: Basic pause functionality
    Given actor has MANAGER_ROLE
    When manager calls StakingVault.pause()
    Then system should be paused
    And stake/unstake operations should be blocked
```

### TC9: Basic Unpause Usage (UC5)

```gherkin
Feature: Pausable Library Usage
  Scenario: Basic unpause functionality
    Given actor has MANAGER_ROLE and system is paused
    When manager calls StakingVault.unpause()
    Then system should be unpaused
    And operations should be enabled again
```

### TC10: Basic Role Verification - Manager (UC14)

```gherkin
Feature: Basic Access Control
  Scenario: Verify MANAGER_ROLE enforcement
    Given user does not have MANAGER_ROLE
    When user attempts to call pause()
    Then transaction should revert with AccessControl error
```

## Admin Role Tests

### TC11: Emergency Token Recovery (UC6)

```gherkin
Feature: Emergency Recovery
  Scenario: Multisig recovers tokens from contract
    Given actor has MULTISIG_ROLE
    And StakingVault has sufficient token balance
    And recovery amount is greater than zero
    When multisig calls emergencyRecover(token, amount)
    Then specified tokens should be transferred to multisig
    And contract balance should decrease by amount
```

### TC12: Role Management (UC7)

```gherkin
Feature: Role Management
  Scenario: Admin grants role to address
    Given actor has DEFAULT_ADMIN_ROLE
    And target address does not have specific role
    When admin calls grantRole(role, address)
    Then target address should have the role
    And RoleGranted event should be emitted

  Scenario: Admin revokes role from address
    Given actor has DEFAULT_ADMIN_ROLE
    And target address has specific role
    When admin calls revokeRole(role, address)
    Then target address should lose the role
    And RoleRevoked event should be emitted
```

## Query Function Tests

### TC13: Get Stake Information (UC3)

```gherkin
Feature: Stake Queries
  Scenario: Query specific stake details
    Given user has an active stake
    When getStake(staker, stakeId) is called
    Then stake details should be returned
    And details should include amount, stakeDay, unstakeDay, daysLock, isFromClaim
    And no state changes should occur
```

### TC14: Get Staker Information (UC3)

```gherkin
Feature: Staker Queries
  Scenario: Query staker summary information
    Given user has multiple stakes
    When getStakerInfo(staker) is called
    Then staker info should be returned
    And info should include stakesCount, totalStaked, lastCheckpointDay
    And no state changes should occur
```

### TC15: Historical Balance Queries (UC9)

```gherkin
Feature: Historical Tracking
  Scenario: Query historical staking balance
    Given staking activity has occurred over time
    And checkpoints have been created
    When getStakerBalanceAt(staker, targetDay) is called
    Then accurate historical balance should be returned
    And binary search should be used for efficiency
    And query should complete in O(log n) time
    And no state changes should occur
```

### TC16: Batch Historical Queries (UC9)

```gherkin
Feature: Batch Historical Queries
  Scenario: Query multiple stakers' historical balances
    Given multiple stakers with historical data
    When batchGetStakerBalances(stakers[], targetDay) is called
    Then array of historical balances should be returned
    And results should match individual queries
    And operation should be gas-efficient
    And no state changes should occur
```

### TC17: Global Statistics (UC9)

```gherkin
Feature: Global Statistics
  Scenario: Query current total staked amount
    Given multiple active stakes exist
    When getCurrentTotalStaked() is called
    Then current total should equal sum of all active stakes
    And value should match internal tracking

  Scenario: Query daily snapshot
    Given stakes have been created/removed on specific day
    When getDailySnapshot(day) is called
    Then snapshot should show total amount and count for that day
    And historical data should be accurate
```

### TC18: Staker Enumeration (UC10)

```gherkin
Feature: Staker Enumeration
  Scenario: Paginated staker retrieval
    Given multiple unique stakers exist
    When getStakersPaginated(offset, limit) is called
    Then correct subset of stakers should be returned
    And pagination should work correctly
    And total count should match getTotalStakersCount()
```

## Error Handling Tests

### TC19: Invalid Stake ID (UC12)

```gherkin
Feature: Stake Validation
  Scenario: User attempts operation with non-existent stake ID
    Given user provides invalid stake ID
    When user attempts unstake(invalidStakeId)
    Then transaction should revert with StakeNotFound error
    And error should include staker and stakeId
    And no tokens should be transferred
```

### TC20: Already Unstaked Stake (UC12)

```gherkin
Feature: Stake State Validation
  Scenario: User attempts to unstake already unstaked stake
    Given user has previously unstaked a stake
    And stake has unstakeDay != 0
    When user attempts to unstake same stake again
    Then transaction should revert with StakeAlreadyUnstaked error
    And no tokens should be transferred
```

### TC21: Not Stake Owner (UC12) - Covered by TC19

```gherkin
Feature: Ownership Validation
  Scenario: User attempts to unstake someone else's stake
    Given stakeId belongs to userB
    When userA attempts to call unstake(stakeId)
    Then the transaction should revert with StakeNotFound error
    And This is because the design of StakingStorage uses `msg.sender` to look up stakes, so the stakeId is not found for the caller. This scenario is covered by TC19.
    And no tokens should be transferred
```

### TC22: Basic Pausable Verification (UC13)

```gherkin
Feature: Pausable Library Usage
  Scenario: Operations blocked when paused
    Given the staking system is paused
    When user calls stake() or unstake()
    Then transaction should revert with Pausable error
```

## Security Tests

### TC23: ReentrancyGuard Basic Usage Verification (UC15)

```gherkin
Feature: ReentrancyGuard Library Usage
  Scenario: Verify nonReentrant modifier usage
    Given StakingVault functions making external calls
    When stake() and unstake() are called
    Then these functions should have nonReentrant modifier
    And normal operations should work with protection in place
```

### TC24: AccessControl Basic Usage Verification (UC14)

```gherkin
Feature: AccessControl Library Usage
  Scenario: Basic role enforcement verification
    Given user does not have CONTROLLER_ROLE
    When user attempts to call StakingStorage.createStake directly
    Then transaction should revert with AccessControl error
```

## Core Business Logic Tests

### TC25: Basic Data Integrity (UC16-17)

```gherkin
Feature: Core Data Consistency
  Scenario: Stake and unstake state consistency
    Given multiple stake and unstake operations
    When operations complete
    Then global currentTotalStaked should equal sum of active stakes
    And user totals should match individual stakes
    And state should be consistent across contracts
```

## Integration Tests

### TC26: Vault-Storage Integration (UC19)

```gherkin
Feature: Contract Integration
  Scenario: Basic vault-storage coordination
    Given both contracts are deployed and configured
    When staking operations are performed
    Then vault should correctly call storage functions
    And CONTROLLER_ROLE should be properly enforced
    And data should remain consistent across contracts
```

### TC27: Token Integration (UC18)

```gherkin
Feature: Token Integration
  Scenario: Basic token operations
    Given standard ERC20 token
    When stake/unstake operations occur
    Then token transfers should work correctly
    And balances should be updated appropriately
```

### TC28: Basic Time Lock Validation

```gherkin
Feature: Time Lock Business Logic
  Scenario: Realistic time lock boundaries (7-365 days)
    Given stake with 30 day time lock
    When 30 days have passed
    Then unstaking should be allowed
    And time lock validation should work correctly
```

# ═══════════════════════════════════════════════════════════════════════════

# 🔥 MISSING TEST CASES - CRITICAL FOR AUDIT READINESS

# ═══════════════════════════════════════════════════════════════════════════

## REWARD SYSTEM TESTS

### TC_R01: Strategy Registration (UC21)

```gherkin
Feature: Strategy Registration and Management
  Scenario: Successfully register new reward strategy
    Given manager has MANAGER_ROLE
    And strategy contract implements IRewardStrategy
    When manager calls StrategiesRegistry.registerStrategy(strategyId, strategyAddress)
    Then strategy should be registered with the given ID
    And StrategyRegistered event should be emitted
```

### TC_R02: Pool Lifecycle (UC22)

```gherkin
Feature: Pool Lifecycle Management
  Scenario: Successfully create and advance a pool
    Given manager has MANAGER_ROLE
    When manager calls PoolManager.upsertPool() with valid parameters
    Then a new pool should be created in the ANNOUNCED state
    And PoolUpserted and PoolStateChanged events should be emitted
    When the current day advances past the pool's startDay
    And updatePoolState() is called
    Then the pool state should transition to ACTIVE
    When the current day advances past the pool's endDay
    And updatePoolState() is called
    Then the pool state should transition to ENDED
    When manager calls finalizePool() with the total weight
    Then the pool state should transition to CALCULATED
    And the total weight should be stored
```

### TC_R03: Immediate Reward Claim (UC23)

```gherkin
Feature: Immediate Reward Claiming
  Scenario: User claims an immediate reward
    Given a USER_CLAIMABLE strategy is registered and funded
    And a user has an active stake
    When the user calls RewardManager.claimImmediateReward(strategyId, stakeId)
    Then the reward amount is calculated based on full days staked
    And the tokens are transferred to the user
    And the user's lastClaimDay is updated to the current day
    And an ImmediateRewardClaimed event is emitted
```

### TC_R04: Granted Reward Claim (UC24)

```gherkin
Feature: Granted Reward Claiming
  Scenario: User claims a granted reward
    Given an ADMIN_GRANTED strategy is registered
    And an admin has granted a reward to a user in the RewardBookkeeper
    When the user calls RewardManager.claimGrantedRewards()
    Then the RewardManager fetches the claimable rewards from the bookkeeper
    And the total token amount is transferred to the user
    And the RewardManager instructs the bookkeeper to mark the rewards as claimed
    And a GrantedRewardsClaimed event is emitted
```

### TC_R05: Immediate Reward Restake (UC25)

```gherkin
Feature: Immediate Reward Restaking
  Scenario: User claims and restakes an immediate reward
    Given a USER_CLAIMABLE strategy is registered and funded
    And a user has an active stake
    When the user calls RewardManager.claimImmediateAndRestake(strategyId, stakeId, daysLock)
    Then the reward amount is calculated
    And the reward tokens are transferred to the StakingVault
    And the StakingVault's stakeFromClaim() function is called to create a new stake for the user
    And the user's lastClaimDay is updated
```

### TC_SCS01: Simple Strategy Full Period Calculation

```gherkin
Feature: Simple User Claimable Strategy Calculation
  Scenario: User has an active stake for the full period
    Given a user's stake was active for a full period
    And the reward rate is set
    When calculateReward is called for that period
    Then the returned reward should be (stake.amount * rate * days)
```

### TC_SCS02: Simple Strategy Partial Period Calculation

```gherkin
Feature: Simple User Claimable Strategy Calculation
  Scenario: User's stake was only active for a portion of the claim period
    Given a user's stake starts or ends within the claim period
    When calculateReward is called
    Then the reward should be calculated only for the effective days of overlap
```

### TC_RBK01: RewardBookkeeper Query Functions

```gherkin
Feature: RewardBookkeeper Data Queries
  Scenario: Querying a user with a mix of claimed and unclaimed rewards
    Given a user has multiple rewards, some of which are claimed
    When getUserClaimableAmount is called, it should return the sum of only unclaimed rewards
    When getUserClaimableRewards is called, it should return the rewards and indices of only unclaimed rewards
    When getUserRewardsPaginated is called, it should return the correct slice of all rewards
```

### TC_SR01: Strategy Removal

```gherkin
Feature: Strategy Registry Management
  Scenario: Manager successfully removes a strategy
    Given a strategy is registered with a specific ID
    When a manager calls removeStrategy with that ID
    Then isStrategyRegistered for that ID should return false
```

## GRANTED REWARD STORAGE TESTS (MISSING)

### TC_GRS01: Grant Reward Operations (UC26)

```gherkin
Feature: Reward Grant Management
  Scenario: Successfully grant reward to user
    Given caller has CONTROLLER_ROLE
    And reward parameters are valid (user, strategyId, version, amount, epochId)
    And amount is greater than zero
    When grantReward(user, strategyId, version, amount, epochId) is called
    Then reward should be added to user's reward array
    And reward should be marked as unclaimed
    And RewardGranted event should be emitted with correct parameters
    And reward should be queryable via getUserRewards()

  Scenario: Grant reward with zero amount
    Given caller has CONTROLLER_ROLE
    And amount is zero
    When grantReward is called with zero amount
    Then operation should complete (zero rewards are valid)
    And reward should be recorded with amount = 0

  Scenario: Grant reward with maximum uint128 amount
    Given caller has CONTROLLER_ROLE
    And amount is type(uint128).max
    When grantReward is called
    Then operation should complete without overflow
    And reward should be recorded accurately

  Scenario: Unauthorized reward granting
    Given caller does not have CONTROLLER_ROLE
    When grantReward is called
    Then transaction should revert with access control error
    And no reward should be granted
```

### TC_GRS02: Single Reward Claiming (UC26)

```gherkin
Feature: Single Reward Claiming State Management
  Scenario: Successfully mark single reward as claimed
    Given user has unclaimed rewards
    And caller has CONTROLLER_ROLE
    And reward index is valid
    When markRewardClaimed(user, rewardIndex) is called
    Then reward at index should be marked as claimed
    And RewardClaimed event should be emitted with user, index, amount
    And reward should no longer appear in claimable queries

  Scenario: Mark already claimed reward as claimed
    Given user has reward that is already claimed
    When markRewardClaimed is called for same reward
    Then transaction should revert with RewardAlreadyClaimed error
    And error should include the reward index

  Scenario: Mark reward with invalid index
    Given user has rewards array of length N
    When markRewardClaimed is called with index >= N
    Then transaction should revert with array bounds error

  Scenario: Unauthorized reward claiming
    Given caller does not have CONTROLLER_ROLE
    When markRewardClaimed is called
    Then transaction should revert with access control error
```

### TC_GRS03: Batch Reward Claiming (UC26)

```gherkin
Feature: Batch Reward Claiming State Management
  Scenario: Successfully mark multiple rewards as claimed
    Given user has multiple unclaimed rewards
    And caller has CONTROLLER_ROLE
    And reward indices array contains valid indices
    When batchMarkClaimed(user, indices[]) is called
    Then all specified rewards should be marked as claimed
    And BatchRewardsClaimed event should be emitted
    And event should include total amount and count of claimed rewards

  Scenario: Batch claim with mix of claimed and unclaimed rewards
    Given batch includes some already-claimed rewards
    When batchMarkClaimed is called
    Then only unclaimed rewards should be processed
    And already-claimed rewards should be skipped silently
    And event should reflect only newly claimed rewards

  Scenario: Batch claim with empty array
    Given indices array is empty
    When batchMarkClaimed is called
    Then operation should complete without error
    And BatchRewardsClaimed event should show zero amount and count

  Scenario: Batch claim with duplicate indices
    Given indices array contains duplicate values
    When batchMarkClaimed is called
    Then each reward should only be claimed once
    And subsequent attempts on same index should be skipped
```

### TC_GRS04: User Rewards Retrieval (UC26)

```gherkin
Feature: User Reward History Queries
  Scenario: Get rewards for user with no rewards
    Given user has never received any rewards
    When getUserRewards(user) is called
    Then empty array should be returned
    And function should not revert

  Scenario: Get rewards for user with single reward
    Given user has been granted one reward
    When getUserRewards is called
    Then array with single reward should be returned
    And reward data should match granted parameters

  Scenario: Get rewards for user with multiple rewards
    Given user has been granted multiple rewards from different strategies/epochs
    When getUserRewards is called
    Then complete array should be returned in chronological order
    And all reward details should be accurate

  Scenario: Get rewards with mix of claimed and unclaimed
    Given user has mix of claimed and unclaimed rewards
    When getUserRewards is called
    Then all rewards should be returned regardless of claimed status
    And claimed flags should be accurate
```

### TC_GRS05: Claimable Amount Calculation (UC26)

```gherkin
Feature: Claimable Amount Calculation
  Scenario: Calculate claimable amount for user with no rewards
    Given user has no rewards
    When getUserClaimableAmount(user) is called
    Then zero should be returned

  Scenario: Calculate claimable amount for user with all rewards claimed
    Given user has rewards but all are marked as claimed
    When getUserClaimableAmount is called
    Then zero should be returned

  Scenario: Calculate claimable amount for user with all rewards unclaimed
    Given user has multiple unclaimed rewards with amounts [100, 200, 300]
    When getUserClaimableAmount is called
    Then 600 should be returned (sum of all amounts)

  Scenario: Calculate claimable amount with mix of claimed/unclaimed
    Given user has rewards: [100 claimed, 200 unclaimed, 300 unclaimed]
    When getUserClaimableAmount is called
    Then 500 should be returned (sum of unclaimed only)

  Scenario: Calculate claimable amount with large numbers
    Given user has unclaimed rewards near uint128 maximum
    When getUserClaimableAmount is called
    Then calculation should not overflow
    And accurate sum should be returned
```

### TC_GRS06: Claimable Rewards with Indices (UC26)

```gherkin
Feature: Claimable Rewards Query with Index Optimization
  Scenario: Get claimable rewards for user with no rewards
    Given user has no rewards
    When getUserClaimableRewards(user) is called
    Then empty arrays should be returned for both rewards and indices

  Scenario: Get claimable rewards for user with all rewards claimed
    Given user has rewards but all are claimed
    When getUserClaimableRewards is called
    Then empty arrays should be returned

  Scenario: Get claimable rewards with nextClaimableIndex optimization
    Given user has 100 rewards where first 50 are claimed
    And _nextClaimableIndex[user] is 50
    When getUserClaimableRewards is called
    Then function should start checking from index 50
    And should return unclaimed rewards from index 50 onwards with correct indices

  Scenario: Get claimable rewards with mixed claimed status
    Given user has rewards [claimed, unclaimed, claimed, unclaimed]
    When getUserClaimableRewards is called
    Then should return unclaimed rewards with indices [1, 3]
    And reward data should match those at indices 1 and 3
```

### TC_GRS07: Epoch-Specific Rewards (UC26)

```gherkin
Feature: Epoch-Specific Reward Queries
  Scenario: Get rewards for epoch with no rewards
    Given user has no rewards from specified epochId
    When getUserEpochRewards(user, epochId) is called
    Then empty array should be returned

  Scenario: Get rewards for specific epoch with multiple rewards
    Given user has rewards from epochs [1, 2, 1, 3, 2]
    When getUserEpochRewards(user, 2) is called
    Then should return rewards from positions [1, 4] (epoch 2 rewards only)

  Scenario: Get immediate rewards (epoch 0)
    Given user has mix of immediate rewards (epochId = 0) and epoch rewards
    When getUserEpochRewards(user, 0) is called
    Then should return only immediate rewards with epochId = 0

  Scenario: Get rewards for non-existent epoch
    Given no rewards exist for specified epochId
    When getUserEpochRewards is called
    Then empty array should be returned
    And function should not revert
```

### TC_GRS08: Paginated Rewards (UC26)

```gherkin
Feature: Paginated Reward Queries
  Scenario: Get paginated rewards with valid offset and limit
    Given user has 100 rewards
    When getUserRewardsPaginated(user, 20, 10) is called
    Then should return rewards from indices 20-29 (10 items)
    And returned array should have length 10

  Scenario: Get paginated rewards with offset beyond array length
    Given user has 50 rewards
    When getUserRewardsPaginated(user, 100, 10) is called
    Then empty array should be returned
    And function should not revert

  Scenario: Get paginated rewards with limit exceeding remaining items
    Given user has 50 rewards
    When getUserRewardsPaginated(user, 45, 10) is called
    Then should return rewards from indices 45-49 (5 items)
    And returned array should have length 5

  Scenario: Get paginated rewards with zero limit
    Given user has rewards
    When getUserRewardsPaginated(user, 0, 0) is called
    Then empty array should be returned

  Scenario: Pagination boundary conditions
    Given user has exactly 10 rewards
    When getUserRewardsPaginated(user, 0, 10) is called
    Then should return all 10 rewards
    When getUserRewardsPaginated(user, 10, 10) is called
    Then should return empty array
```

### TC_GRS09: Next Claimable Index Management (UC26)

```gherkin
Feature: Claiming Index Optimization
  Scenario: Update index after claiming first reward
    Given user has rewards [unclaimed, unclaimed, unclaimed]
    And _nextClaimableIndex[user] is 0
    When first reward is claimed and updateNextClaimableIndex is called
    Then _nextClaimableIndex[user] should remain 0 (still unclaimed rewards from start)

  Scenario: Update index after claiming first few rewards
    Given user has rewards [claimed, claimed, unclaimed, unclaimed]
    When updateNextClaimableIndex(user) is called
    Then _nextClaimableIndex[user] should be set to 2 (first unclaimed index)

  Scenario: Update index when all rewards are claimed
    Given user has rewards and all are claimed
    When updateNextClaimableIndex is called
    Then _nextClaimableIndex[user] should be set to array length
    And subsequent getUserClaimableRewards should return empty quickly

  Scenario: Update index for user with no rewards
    Given user has no rewards
    When updateNextClaimableIndex is called
    Then _nextClaimableIndex[user] should be 0
    And function should not revert

  Scenario: Unauthorized index update
    Given caller does not have CONTROLLER_ROLE
    When updateNextClaimableIndex is called
    Then transaction should revert with access control error
```

## FLAG SYSTEM TESTS (MISSING)

### TC_F01: Basic Flag Operations (UC20)

```gherkin
Feature: Flag Library Operations
  Scenario: Set flag bit
    Given flag value starts at 0
    When Flags.set(flags, bitPosition) is called
    Then specified bit should be set to 1
    And other bits should remain unchanged
    And result should be returned

  Scenario: Unset flag bit
    Given flag has specific bit set
    When Flags.unset(flags, bitPosition) is called
    Then specified bit should be set to 0
    And other bits should remain unchanged

  Scenario: Check flag bit status
    Given flags with various bits set
    When Flags.isSet(flags, bitPosition) is called
    Then should return true if bit is set
    And should return false if bit is unset
    And should handle all 16 bit positions
```

### TC_F02: Stake Flag Integration (UC20)

```gherkin
Feature: Stake Flag Usage
  Scenario: Mark stake as from claim
    Given stake is created via stakeFromClaim
    When stake flags are checked
    Then IS_FROM_CLAIM_BIT should be set
    And flag should be queryable via Flags.isSet
    And stake should be identifiable as claim-originated

  Scenario: Regular stake flag handling
    Given stake is created via regular stake()
    When stake flags are checked
    Then IS_FROM_CLAIM_BIT should not be set
    And other flag bits should be available for future use
    And flag operations should work correctly

  Scenario: Multiple flag combinations
    Given stake needs multiple property flags
    When multiple flags are set simultaneously
    Then all flags should be maintained correctly
    And individual flags should be queryable
    And combinations should work as expected
```

### TC_F03: Flag System Extensibility (UC20)

```gherkin
Feature: Future Flag Extensions
  Scenario: Add new flag types
    Given system needs new stake properties
    When new flag constants are defined
    Then new flags should work with existing system
    And should not interfere with existing flags
    And should be backward compatible

  Scenario: Flag boundary conditions
    Given flags using all 16 available bits
    When flag operations are performed
    Then all bit positions should work correctly
    And should handle edge cases (bit 0, bit 15)
    And should not overflow or corrupt data

  Scenario: Flag persistence and queries
    Given stakes with various flag combinations
    When stakes are queried after time
    Then flags should persist correctly
    And should be queryable efficiently
    And should support filtering and analytics
```

## CROSS-SYSTEM INTEGRATION TESTS (CRITICAL)

### TC_I01: Basic Staking-Reward Data Integration (UC Integration)

```gherkin
Feature: Simplified Historical Data Integration
  Scenario: Basic reward calculation using staking data
    Given users have staking history
    When reward calculations are performed
    Then calculations should use accurate staking balances
    And results should match staking behavior
```

### TC_I02: Basic Multi-User Reward Distribution (UC Integration)

```gherkin
Feature: Simplified Multi-User Operations
  Scenario: Basic batch reward processing
    Given multiple users with active stakes
    When batch reward processing occurs
    Then all eligible users should receive correct rewards
    And state should remain consistent
```

### TC_I03: Basic Real-Time Staking During Epochs (UC Integration)

```gherkin
Feature: Simplified Dynamic Staking
  Scenario: Basic stake during active epoch
    Given epoch is currently active
    When user stakes tokens during epoch period
    Then stake should be properly accounted for in rewards
    And calculations should be correct
```

### TC_I04: Basic End-to-End User Journey (UC Integration)

```gherkin
Feature: Simplified User Experience Flow
  Scenario: Basic stake, earn, claim workflow
    Given user starts with tokens
    When user stakes, earns rewards, and claims
    Then all operations should work correctly
    And user should receive expected rewards
    And state should be consistent
```

### TC_I05: Basic Cross-Contract Event Coordination (UC Integration)

```gherkin
Feature: Simplified Event Coordination
  Scenario: Basic event coordination
    Given operations span multiple contracts
    When operations complete
    Then events should be emitted correctly
    And event data should be consistent
```

### TC_I06: Basic System State Consistency (UC Integration)

```gherkin
Feature: Simplified State Validation
  Scenario: Basic state consistency validation
    Given multiple operations across system components
    When operations complete
    Then total staked should equal sum of individual stakes
    And basic invariants should hold
```

### TC_I07: Basic System Evolution Support (UC Future)

```gherkin
Feature: Simplified System Evolution
  Scenario: Basic extensibility validation
    Given system needs to support new features
    When new components are added
    Then existing functionality should continue working
    And integration should be possible
```

---

## Summary

This document defines **62 focused test cases** for the complete Token Staking System:

- **Core Staking Tests (TC1-TC28)**: 28 test cases covering StakingVault and StakingStorage with focus on business logic
- **Reward System Tests (TC_R01-TC_R30)**: 30 test cases covering complete reward functionality
- **Flag System Tests (TC_F01-TC_F03)**: 3 test cases for extensible flag operations
- **Integration Tests (TC_I01-TC_I07)**: 7 simplified test cases for cross-system integration

Each test case focuses on business logic and core functionality rather than implementation details or external library testing. The test cases provide practical coverage of all use cases defined in `use_cases.md` and ensure the system is audit-ready without over-engineering.
