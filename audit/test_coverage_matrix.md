# Token Staking System: Test Coverage Matrix

## Overview

This matrix maps use cases to test cases and functions, ensuring practical coverage of the Token Staking System. It provides traceability from requirements through implementation to testing for both core staking and reward management functionality.

**Scope**: Complete Token Staking System including core staking contracts (StakingVault.sol and StakingStorage.sol) and reward management system (RewardManager.sol, PoolManager.sol, StrategiesRegistry.sol, RewardBookkeeper.sol, and strategy implementations).

**Note**: Test specifications focus on business logic validation rather than implementation details, external library internals, or unrealistic edge cases.

## Use Case to Test Cases Mapping

| Use Case                              | Description                         | Test Cases                                                               |
| ------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------ |
| **UC1: Direct Token Staking**         | User stakes tokens with time lock   | TC1, TC4, TC5, TC22                                                      |
| **UC2: Stake Unstaking**              | User unstakes matured tokens        | TC2, TC3, TC22                                                           |
| **UC3: Query Active Stakes**          | Query stake and balance information | TC13, TC14                                                               |
| **UC4: Pause System**                 | Manager pauses staking system       | TC8, TC10, TC22                                                          |
| **UC5: Unpause System**               | Manager unpauses system             | TC9                                                                      |
| **UC6: Emergency Token Recovery**     | Multisig recovers tokens            | TC11, TC12, TC24                                                         |
| **UC7: Role Management**              | Admin manages roles                 | TC12, TC24                                                               |
| **UC8: Stake from Claim**             | Claim contract stakes for user      | TC6, TC7                                                                 |
| **UC9: Historical Balance Queries**   | Query historical staking data       | TC15, TC16, TC17                                                         |
| **UC10: Staker Enumeration**          | Enumerate stakers for analytics     | TC18                                                                     |
| **UC20: Stake Flag System**           | Manage stake flags and properties   | TC_F01, TC_F02, TC_F03                                                   |
| **UC21: Reward Strategy Management**  | Register and manage strategies      | TC_R01, TC_R02, TC_R03                                                   |
| **UC22: Pool Lifecycle Management**      | Manage pool state transitions      | TC_R02                                                   |
| **UC23: Immediate Reward Claiming** | User claims APR-style rewards         | TC_R03                                                   |
| **UC24: Granted Reward Claiming**   | User claims pool-based rewards      | TC_R04                                                   |
| **UC25: Immediate Reward Restaking**| User claims and restakes rewards    | TC_R05                                                   |
| **UC26: Reward Storage Management**   | Track granted rewards               | TC_GRS01, TC_GRS02, TC_GRS03, TC_GRS04, TC_GRS05 |

## Function to Test Cases Matrix

| Contract               | Function                                        | Required Test Cases              |
| ---------------------- | ----------------------------------------------- | -------------------------------- |
| **StakingVault**       | `stake(uint128, uint16)`                        | TC1, TC4, TC5, TC22, TC23        |
| **StakingVault**       | `unstake(bytes32)`                              | TC2, TC3, TC22, TC23             |
| **StakingVault**       | `stakeFromClaim(address, uint128, uint16)`      | TC6, TC7, TC22, TC_R05           |
| **StakingVault**       | `pause()`                                       | TC8, TC10                        |
| **StakingVault**       | `unpause()`                                     | TC9, TC10                        |
| **StakingVault**       | `emergencyRecover(IERC20, uint256)`             | TC11, TC12, TC24                 |
| **StakingStorage**     | `createStake(address, uint128, uint16, uint16)` | TC1, TC6, TC24, TC25, TC26, TC27 |
| **StakingStorage**     | `removeStake(address, bytes32)`                 | TC2, TC24, TC25, TC26, TC27      |
| **StakingStorage**     | `getStake(address, bytes32)`                    | TC2, TC13                        |
| **StakingStorage**     | `isActiveStake(address, bytes32)`               | TC13                             |
| **StakingStorage**     | `getStakerInfo(address)`                        | TC14, TC26                       |
| **StakingStorage**     | `getStakerBalance(address)`                     | TC14, TC26                       |
| **StakingStorage**     | `getStakerBalanceAt(address, uint16)`           | TC15, TC25                       |
| **StakingStorage**     | `batchGetStakerBalances(address[], uint16)`     | TC16                             |
| **StakingStorage**     | `getDailySnapshot(uint16)`                      | TC17, TC26                       |
| **StakingStorage**     | `getCurrentTotalStaked()`                       | TC17, TC26                       |
| **StakingStorage**     | `getStakersPaginated(uint256, uint256)`         | TC18                             |
| **StakingStorage**     | `getTotalStakersCount()`                        | TC18, TC26                       |
| **RewardManager**      | `depositForStrategy(bytes32, uint256)`          | TC_R03                           |
| **RewardManager**      | `claimImmediateReward(bytes32, bytes32)`        | TC_R03                           |
| **RewardManager**      | `claimGrantedRewards()`                         | TC_R04                           |
| **RewardManager**      | `claimImmediateAndRestake(bytes32, bytes32, uint16)` | TC_R05                       |
| **PoolManager**        | `upsertPool(uint256, uint16, uint16, uint256, bytes32)` | TC_R02                     |
| **PoolManager**        | `updatePoolState(uint256)`                      | TC_R02                           |
| **PoolManager**        | `finalizePool(uint256, uint256)`                | TC_R02                           |
| **StrategiesRegistry** | `registerStrategy(bytes32, address)`            | TC_R01                           |
| **StrategiesRegistry** | `removeStrategy(bytes32)`                       | TC_R01                           |
| **RewardBookkeeper**   | `grantReward()`                                 | TC_GRS01                         |
| **RewardBookkeeper**   | `markRewardClaimed()`                           | TC_GRS02                         |
| **RewardBookkeeper**   | `batchMarkClaimed()`                            | TC_GRS03, TC_R04                 |
| **RewardBookkeeper**   | `getUserRewards()`                              | TC_GRS04                         |
| **RewardBookkeeper**   | `getUserClaimableAmount()`                      | TC_GRS05                         |
| **RewardBookkeeper**   | `getUserClaimableRewards()`                     | TC_GRS06, TC_R04                 |
| **RewardBookkeeper**   | `getUserEpochRewards()`                         | TC_GRS07                         |
| **RewardBookkeeper**   | `getUserRewardsPaginated()`                     | TC_GRS08, TC_RBK01               |
| **RewardBookkeeper**   | `updateNextClaimableIndex()`                    | TC_GRS09                         |
| **Flags**              | `set(uint16, uint8)`                            | TC_F01, TC_F02, TC_F03           |
| **Flags**              | `unset(uint16, uint8)`                          | TC_F01, TC_F02, TC_F03           |
| **Flags**              | `isSet(uint16, uint8)`                          | TC_F01, TC_F02, TC_F03           |
| **SimpleUserClaimableStrategy** | `calculateReward()`                    | TC_SCS01, TC_SCS02               |

## Test Case Implementation Status

| Test Case    | Implemented In                                                                               | Status      |
| ------------ | -------------------------------------------------------------------------------------------- | ----------- |
| **TC1**      | tests/unit/StakingVault.t.sol::test_TC1_SuccessfulDirectStake                                | Implemented |
| **TC2**      | tests/unit/StakingVault.t.sol::test_TC2_SuccessfulUnstaking                                  | Implemented |
| **TC3**      | tests/unit/StakingVault.t.sol::test_TC3_FailedUnstakingStakeNotMatured                       | Implemented |
| **TC4**      | tests/unit/StakingVault.t.sol::test_TC4_SafeERC20BasicUsage                                  | Implemented |
| **TC5**      | tests/unit/StakingVault.t.sol::test_TC5_FailedStakingZeroAmount                              | Implemented |
| **TC6**      | tests/unit/StakingVault.t.sol::test_TC6_StakeFromClaimContract                               | Implemented |
| **TC7**      | tests/unit/StakingVault.t.sol::test_TC7_FailedClaimStakeUnauthorized                         | Implemented |
| **TC8**      | tests/unit/StakingVault.t.sol::test_TC8_PauseSystem                                          | Implemented |
| **TC9**      | tests/unit/StakingVault.t.sol::test_TC9_UnpauseSystem                                        | Implemented |
| **TC10**     | tests/unit/StakingVault.t.sol::test_TC10_FailedPauseUnauthorized                             | Implemented |
| **TC11**     | tests/unit/StakingVault.t.sol::test_TC11_EmergencyTokenRecovery                              | Implemented |
| **TC12**     | tests/unit/StakingVault.t.sol::test_TC12_RoleManagement                                      | Implemented |
| **TC13**     | tests/unit/StakingStorage.t.sol::test_TC13_GetStakeInformation                               | Implemented |
| **TC14**     | tests/unit/StakingStorage.t.sol::test_TC14_GetStakerInformation                              | Implemented |
| **TC15**     | tests/unit/StakingStorage.t.sol::test_TC15_HistoricalBalanceQueries                          | Implemented |
| **TC16**     | tests/unit/StakingStorage.t.sol::test_TC16_BatchHistoricalQueries                            | Implemented |
| **TC17**     | tests/unit/StakingStorage.t.sol::test_TC17_GlobalStatistics                                  | Implemented |
| **TC18**     | tests/unit/StakingStorage.t.sol::test_TC18_StakerEnumeration                                 | Implemented |
| **TC22**     | tests/unit/StakingVault.t.sol::test_TC22_PausedSystemOperations                              | Implemented |
| **TC23**     | tests/unit/StakingVault.t.sol::test_TC23_ReentrancyProtection                                | Implemented |
| **TC24**     | tests/integration/VaultStorageIntegration.t.sol::test_TC24_UnauthorizedStorageAccess         | Implemented |
| **TC25**     | tests/integration/VaultStorageIntegration.t.sol::test_TC25_CheckpointCreationOnBalanceChange | Implemented |
| **TC26**     | tests/unit/StakingStorage.t.sol::test_TC26_VaultStorageIntegration                           | Implemented |
| **TC27**     | tests/integration/VaultStorageIntegration.t.sol::test_TC27_CrossContractStateConsistency     | Implemented |
| **TC_F01**   | tests/unit/Flags.t.sol::test_TCF01_SetFlagBit                                                | Implemented |
| **TC_F02**   | tests/unit/Flags.t.sol::test_TCF02_MarkStakeAsFromClaim                                      | Implemented |
| **TC_F03**   | tests/unit/Flags.t.sol::test_TCF03_AddNewFlagTypes                                           | Implemented |
| **TC_R01**   | tests/unit/StrategiesRegistry.t.sol                                                          | Implemented |
| **TC_R02**   | tests/unit/PoolManager.t.sol                                                                 | Implemented |
| **TC_R03**   | tests/unit/RewardManager.t.sol::test_ClaimImmediateReward_Success                            | Implemented |
| **TC_R04**   | tests/unit/RewardManager.t.sol::test_ClaimGrantedRewards_Success                             | Implemented |
| **TC_R05**   | tests/unit/RewardManager.t.sol::test_ClaimImmediateAndRestake_Success                        | Implemented |
| **TC_RBK01** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_SCS01** | tests/unit/SimpleUserClaimableStrategy.t.sol                                                 | Implemented |
| **TC_SCS02** | tests/unit/SimpleUserClaimableStrategy.t.sol                                                 | Implemented |
| **TC_SR01**  | tests/unit/StrategiesRegistry.t.sol                                                          | Implemented |
| **TC_GRS01** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS02** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS03** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS04** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS05** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS06** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS07** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS08** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |
| **TC_GRS09** | tests/unit/RewardBookkeeper.t.sol                                                            | Implemented |

## Gap Analysis

### Functions Missing Test Cases

None - all functions have mapped test cases.

### Investigation Workflow

1. **Check forge coverage**: `forge coverage --report summary`
2. **Find uncovered functions** in coverage report
3. **Look up required test cases** in Function to Test Cases Matrix
4. **Check implementation status** in Test Case Implementation Status table
5. **Create missing tests** for test cases marked as "Missing"
