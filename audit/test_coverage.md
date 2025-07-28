Compiling 78 files with Solc 0.8.30
Solc 0.8.30 finished in 2.80s
Compiler run successful with warnings:
Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> src/reward-system/ClaimsJournal.sol:63:9:
   |
63 |         bool _isPoolSizeDependent,
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FullStakingStrategy.t.sol:23:9:
   |
23 |         address _owner,
   |         ^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:45:9:
   |
45 |         address user,
   |         ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:46:9:
   |
46 |         IStakingStorage.Stake calldata stake,
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:47:9:
   |
47 |         uint16 poolStartDay,
   |         ^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:48:9:
   |
48 |         uint16 poolEndDay,
   |         ^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:49:9:
   |
49 |         uint16 lastClaimDay
   |         ^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:55:9:
   |
55 |         address user,
   |         ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:56:9:
   |
56 |         IStakingStorage.Stake calldata stake,
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:57:9:
   |
57 |         uint256 totalPoolWeight,
   |         ^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:58:9:
   |
58 |         uint256 totalRewardAmount,
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:59:9:
   |
59 |         uint16 poolStartDay,
   |         ^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:60:9:
   |
60 |         uint16 poolEndDay
   |         ^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/RewardManager.t.sol:45:9:
   |
45 |         uint16 poolStartDay,
   |         ^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/RewardManager.t.sol:46:9:
   |
46 |         uint16 poolEndDay,
   |         ^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/StandardStakingStrategy.t.sol:22:9:
   |
22 |         address _owner,
   |         ^^^^^^^^^^^^^^

Warning (2018): Function state mutability can be restricted to pure
  --> tests/mocks/MockStakingStorage.sol:43:5:
   |
43 |     function isActiveStake(bytes32) external view override returns (bool) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:40:5:
   |
40 |     function createStake(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:48:5:
   |
48 |     function removeStake(address, bytes32) external override {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:51:5:
   |
51 |     function isActiveStake(bytes32) external view override returns (bool) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:54:5:
   |
54 |     function getStakerInfo(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:59:5:
   |
59 |     function getStakerBalance(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:64:5:
   |
64 |     function getStakerBalanceAt(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:70:5:
   |
70 |     function batchGetStakerBalances(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:76:5:
   |
76 |     function getDailySnapshot(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:81:5:
   |
81 |     function getCurrentTotalStaked() external view override returns (uint128) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:84:5:
   |
84 |     function getStakersPaginated(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:90:5:
   |
90 |     function getTotalStakersCount() external view override returns (uint256) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FullStakingStrategy.t.sol:93:5:
   |
93 |     function getStakerStakeIds(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FundingManager.t.sol:44:5:
   |
44 |     function calculateReward(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/FundingManager.t.sol:54:5:
   |
54 |     function calculateReward(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:39:5:
   |
39 |     function createStake(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:47:5:
   |
47 |     function removeStake(address, bytes32) external override {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:50:5:
   |
50 |     function isActiveStake(bytes32) external view override returns (bool) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:53:5:
   |
53 |     function getStakerInfo(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:58:5:
   |
58 |     function getStakerBalance(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:63:5:
   |
63 |     function getStakerBalanceAt(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:69:5:
   |
69 |     function batchGetStakerBalances(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:75:5:
   |
75 |     function getDailySnapshot(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:80:5:
   |
80 |     function getCurrentTotalStaked() external view override returns (uint128) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:83:5:
   |
83 |     function getStakersPaginated(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:89:5:
   |
89 |     function getTotalStakersCount() external view override returns (uint256) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/StandardStakingStrategy.t.sol:92:5:
   |
92 |     function getStakerStakeIds(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Analysing contracts...
Running tests...

Ran 5 tests for tests/unit/FullStakingStrategy.t.sol:FullStakingStrategyTest
[PASS] test_CalculateReward_Eligible_StakedEarlyHeldToEnd() (gas: 53901)
[PASS] test_CalculateReward_Eligible_StakedOnLastGraceDayHeldToEnd() (gas: 53447)
[PASS] test_CalculateReward_Eligible_UnstakedAfterEndDay() (gas: 53712)
[PASS] test_CalculateReward_Eligible_UnstakedOnEndDay() (gas: 54165)
[PASS] test_CalculateReward_ZeroTotalWeight() (gas: 51953)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 1.81ms (541.79µs CPU time)

Ran 7 tests for tests/unit/StandardStakingStrategy.t.sol:StandardStakingStrategyTest
[PASS] test_CalculateReward_FullPeriod() (gas: 54519)
[PASS] test_CalculateReward_NoOverlap() (gas: 52481)
[PASS] test_CalculateReward_PartialPeriod_Start() (gas: 55190)
[PASS] test_CalculateReward_StakeEndsBeforePoolStarts() (gas: 53084)
[PASS] test_CalculateReward_StakeStartsAfterPoolEnds() (gas: 52502)
[PASS] test_CalculateReward_UnstakedDuringPool_NoReStakingAllowed() (gas: 53042)
[PASS] test_CalculateReward_ZeroTotalWeight() (gas: 52142)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 2.24ms (912.33µs CPU time)

Ran 4 tests for tests/unit/StrategiesRegistry.t.sol:StrategiesRegistryTest
[PASS] test_RegisterAndGetStrategy() (gas: 45436)
[PASS] test_RegisterStrategy_Fail_NotManager() (gas: 19138)
[PASS] test_RemoveStrategy_Fail_NotRegistered() (gas: 17396)
[PASS] test_TC_SR01_RemoveStrategy_Success() (gas: 36752)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.47ms (1.80ms CPU time)

Ran 1 test for tests/security/Reentrancy.t.sol:ReentrancyTest
[PASS] test_TC23_ReentrancyOnUnstake() (gas: 436126)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 990.63µs (348.92µs CPU time)

Ran 2 tests for tests/unit/ClaimsJournal.t.sol:ClaimsJournalTest
[PASS] test_RecordClaim_ExclusiveBlocksAll() (gas: 77349)
[PASS] test_RecordClaim_SemiExclusiveLogic() (gas: 110863)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 4.49ms (303.75µs CPU time)

Ran 8 tests for tests/unit/FundingManager.t.sol:FundingManagerTest
[PASS] test_FundStrategy_Fail_NotManager() (gas: 46646)
[PASS] test_FundStrategy_Success() (gas: 98998)
[PASS] test_TransferStrategyBalance_Fail_InsufficientBalance() (gas: 97054)
[PASS] test_TransferStrategyBalance_Fail_NotManager() (gas: 101859)
[PASS] test_TransferStrategyBalance_Success() (gas: 124877)
[PASS] test_WithdrawStrategy_Fail_InsufficientBalance() (gas: 96795)
[PASS] test_WithdrawStrategy_Fail_NotManager() (gas: 101935)
[PASS] test_WithdrawStrategy_Success() (gas: 101397)
Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 5.33ms (1.11ms CPU time)

Ran 25 tests for tests/unit/PoolManager.t.sol:PoolManagerTest
[PASS] test_AssignStrategy_Fail_IfPoolAlreadyStarted() (gas: 49949)
[PASS] test_GetLayerStrategies() (gas: 182343)
[PASS] test_GetPoolCount() (gas: 84857)
[PASS] test_GetPoolLayers() (gas: 289965)
[PASS] test_GetPools() (gas: 99617)
[PASS] test_GetPoolsByDateRange() (gas: 125960)
[PASS] test_GetStrategyExclusivity() (gas: 147444)
[PASS] test_GetStrategyLayer() (gas: 147735)
[PASS] test_HasLayer() (gas: 152865)
[PASS] test_IsPoolActive() (gas: 53128)
[PASS] test_IsPoolCalculated() (gas: 82965)
[PASS] test_IsPoolEnded() (gas: 51368)
[PASS] test_RemoveLayer_Fail_IfNotManager() (gas: 53227)
[PASS] test_RemoveLayer_Fail_IfPoolActive() (gas: 49133)
[PASS] test_RemoveLayer_Success() (gas: 117801)
[PASS] test_RemoveStrategyFromPool_Fail_IfNotManager() (gas: 154083)
[PASS] test_RemoveStrategyFromPool_Fail_IfPoolActive() (gas: 150081)
[PASS] test_RemoveStrategyFromPool_Success() (gas: 121646)
[PASS] test_SetPoolLiveWeight_Fail_IfNotController() (gas: 53174)
[PASS] test_SetPoolLiveWeight_Success() (gas: 75368)
[PASS] test_SetTotalStakeWeight_Fail_IfNotController() (gas: 53826)
[PASS] test_SetTotalStakeWeight_Fail_IfNotEnded() (gas: 52328)
[PASS] test_SetTotalStakeWeight_Success() (gas: 86994)
[PASS] test_UpsertPool_Fail_IfPoolAlreadyStarted() (gas: 49614)
[PASS] test_UpsertPool_Success() (gas: 77897)
Suite result: ok. 25 passed; 0 failed; 0 skipped; finished in 7.69ms (4.77ms CPU time)

Ran 11 tests for tests/unit/StakingStorage.t.sol:StakingStorageTest
[PASS] test_TC13_GetStakeInformation() (gas: 378940)
[PASS] test_TC14_GetStakerInformation() (gas: 452970)
[PASS] test_TC15_HistoricalBalanceQueries() (gas: 691204)
[PASS] test_TC16_BatchHistoricalQueries() (gas: 905607)
[PASS] test_TC17_GlobalStatistics() (gas: 637805)
[PASS] test_TC18_StakerEnumeration() (gas: 910633)
[PASS] test_TC25_BasicDataIntegrity() (gas: 800207)
[PASS] test_TC26_VaultStorageIntegration() (gas: 387834)
[PASS] test_TC27_TokenIntegration() (gas: 381973)
[PASS] test_TC28_BasicTimeLockValidation() (gas: 381407)
[PASS] test_TC28_BasicTimeLockValidation_just1day() (gas: 385241)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 7.58ms (7.22ms CPU time)

Ran 4 tests for tests/unit/RewardManager.t.sol:RewardManagerTest
[PASS] test_ClaimReward_Fail_IfAlreadyClaimed_DependentStrategy() (gas: 242311)
[PASS] test_ClaimReward_Fail_IfExclusiveClaimedOnLayer() (gas: 275471)
[PASS] test_ClaimReward_Success_DependentStrategy() (gas: 222735)
[PASS] test_ClaimReward_Success_IndependentStrategy() (gas: 188578)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 7.92ms (2.18ms CPU time)

Ran 19 tests for tests/unit/StakingVault.t.sol:StakingVaultTest
[PASS] test_TC10_FailedPauseUnauthorized() (gas: 14030)
[PASS] test_TC11_EmergencyTokenRecovery() (gas: 1039098)
[PASS] test_TC12_EmergencyRecoverRole() (gas: 1087733)
[PASS] test_TC12_RoleManagement() (gas: 42532)
[PASS] test_TC19_InvalidStakeId() (gas: 26578)
[PASS] test_TC1_SuccessfulDirectStake() (gas: 374388)
[PASS] test_TC20_FailedUnstakeAlreadyUnstaked() (gas: 370657)
[PASS] test_TC22_PausedSystemOperations() (gas: 389088)
[PASS] test_TC23_ReentrancyProtection() (gas: 538053)
[PASS] test_TC24_AccessControlEnforcement() (gas: 30338)
[PASS] test_TC28_TokenIntegration() (gas: 384546)
[PASS] test_TC2_SuccessfulUnstaking() (gas: 389124)
[PASS] test_TC3_FailedUnstakingStakeNotMatured() (gas: 364442)
[PASS] test_TC4_SafeERC20BasicUsage() (gas: 371625)
[PASS] test_TC5_FailedStakingZeroAmount() (gas: 21004)
[PASS] test_TC6_StakeFromClaimContract() (gas: 326400)
[PASS] test_TC7_FailedClaimStakeUnauthorized() (gas: 20605)
[PASS] test_TC8_PauseSystem() (gas: 38865)
[PASS] test_TC9_UnpauseSystem() (gas: 29236)
Suite result: ok. 19 passed; 0 failed; 0 skipped; finished in 4.10ms (8.46ms CPU time)

Ran 11 tests for tests/integration/VaultStorageIntegration.t.sol:VaultStorageIntegrationTest
[PASS] test_ComplexStakeAndUnstakeLifecycle() (gas: 722764)
[PASS] test_MultipleUsersIntegration() (gas: 599406)
[PASS] test_TC15_HistoricalDataConsistency() (gas: 684276)
[PASS] test_TC24_UnauthorizedStorageAccess() (gas: 316559)
[PASS] test_TC25_CheckpointCreationOnBalanceChange() (gas: 351658)
[PASS] test_TC27_CrossContractStateConsistency() (gas: 546973)
[PASS] test_TC27_VaultStorageCoordination() (gas: 449386)
[PASS] test_TC32_EventParameterVerification() (gas: 354139)
[PASS] test_TC3_TC19_ErrorHandlingIntegration() (gas: 366866)
[PASS] test_TC42_CrossContractEventCoordination() (gas: 370928)
[PASS] test_TC6_StakeFromClaimContract() (gas: 325762)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 4.91ms (4.35ms CPU time)

Ran 7 tests for tests/integration/TokenIntegration.t.sol:TokenIntegrationTest
[PASS] test_TC28_AllowanceChecks() (gas: 421658)
[PASS] test_TC28_BalanceValidation() (gas: 349678)
[PASS] test_TC28_ClaimContractTokenHandling() (gas: 385937)
[PASS] test_TC28_EmergencyTokenRecovery() (gas: 70491)
[PASS] test_TC28_SafeERC20Usage() (gas: 387524)
[PASS] test_TC28_TokenIntegration() (gas: 384546)
[PASS] test_TC28_TokenRelatedErrors() (gas: 345896)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 7.69ms (4.27ms CPU time)

Ran 9 tests for tests/unit/Flags.t.sol:FlagsTest
[PASS] test_TCF01_CheckFlagBitStatus() (gas: 25316)
[PASS] test_TCF01_SetFlagBit() (gas: 8402)
[PASS] test_TCF01_UnsetFlagBit() (gas: 7394)
[PASS] test_TCF02_MarkStakeAsFromClaim() (gas: 320019)
[PASS] test_TCF02_MultipleFlagCombinations() (gas: 6683)
[PASS] test_TCF02_RegularStakeFlagHandling() (gas: 354587)
[PASS] test_TCF03_AddNewFlagTypes() (gas: 6124)
[PASS] test_TCF03_FlagBoundaryConditions() (gas: 18204)
[PASS] test_TCF03_FlagPersistenceAndQueries() (gas: 450413)
Suite result: ok. 9 passed; 0 failed; 0 skipped; finished in 7.73ms (2.36ms CPU time)

Ran 13 test suites in 295.65ms (64.93ms CPU time): 113 tests passed, 0 failed, 0 skipped (113 total tests)

╭----------------------------------------------------------+------------------+------------------+-----------------+-----------------╮
| File                                                     | % Lines          | % Statements     | % Branches      | % Funcs         |
+====================================================================================================================================+
| src/StakingStorage.sol                                   | 91.27% (115/126) | 90.62% (116/128) | 61.54% (16/26)  | 86.96% (20/23)  |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/StakingVault.sol                                     | 92.50% (37/40)   | 89.19% (33/37)   | 80.00% (8/10)   | 88.89% (8/9)    |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/lib/Flags.sol                                        | 100.00% (6/6)    | 100.00% (7/7)    | 100.00% (0/0)   | 100.00% (3/3)   |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/ClaimsJournal.sol                      | 90.91% (20/22)   | 88.89% (16/18)   | 75.00% (9/12)   | 100.00% (4/4)   |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/FundingManager.sol                     | 100.00% (25/25)  | 100.00% (21/21)  | 66.67% (4/6)    | 100.00% (6/6)   |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/PoolManager.sol                        | 100.00% (92/92)  | 97.98% (97/99)   | 76.92% (10/13)  | 100.00% (24/24) |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/RewardManager.sol                      | 89.04% (65/73)   | 94.29% (66/70)   | 62.50% (20/32)  | 83.33% (10/12)  |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/StrategiesRegistry.sol                 | 100.00% (15/15)  | 100.00% (11/11)  | 75.00% (3/4)    | 100.00% (5/5)   |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/strategies/FullStakingStrategy.sol     | 66.67% (14/21)   | 76.47% (13/17)   | 50.00% (1/2)    | 57.14% (4/7)    |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/strategies/StandardStakingStrategy.sol | 56.52% (13/23)   | 76.19% (16/21)   | 100.00% (2/2)   | 28.57% (2/7)    |
|----------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| Total                                                    | 90.74% (402/443) | 92.31% (396/429) | 68.22% (73/107) | 86.00% (86/100) |
╰----------------------------------------------------------+------------------+------------------+-----------------+-----------------╯
