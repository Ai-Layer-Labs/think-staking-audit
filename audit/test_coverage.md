Compiling 78 files with Solc 0.8.30
Solc 0.8.30 finished in 2.50s
Compiler run successful with warnings:
Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FullStakingStrategy.t.sol:23:9:
   |
23 |         address _owner,
   |         ^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:45:9:
   |
45 |         address user, // user
   |         ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:46:9:
   |
46 |         IStakingStorage.Stake calldata stake,
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:47:9:
   |
47 |         uint256 totalPoolWeight,
   |         ^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:48:9:
   |
48 |         uint256 totalRewardAmount,
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:49:9:
   |
49 |         uint16 poolStartDay,
   |         ^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:50:9:
   |
50 |         uint16 poolEndDay,
   |         ^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FundingManager.t.sol:51:9:
   |
51 |         uint16 lastClaimDay
   |         ^^^^^^^^^^^^^^^^^^^

Warning (2072): Unused local variable.
   --> tests/unit/PoolManager.t.sol:346:9:
    |
346 |         uint256 poolId3 = poolManager.upsertPool(0, 30, 40, 0);
    |         ^^^^^^^^^^^^^^^

Warning (2072): Unused local variable.
   --> tests/unit/PoolManager.t.sol:374:9:
    |
374 |         uint256 poolId1 = poolManager.upsertPool(0, 10, 20, 0);
    |         ^^^^^^^^^^^^^^^

Warning (2072): Unused local variable.
   --> tests/unit/PoolManager.t.sol:376:9:
    |
376 |         uint256 poolId2 = poolManager.upsertPool(0, 15, 25, 0);
    |         ^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/RewardManager.t.sol:44:9:
   |
44 |         address user, // user
   |         ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/RewardManager.t.sol:46:9:
   |
46 |         uint256 totalPoolWeight,
   |         ^^^^^^^^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/RewardManager.t.sol:47:9:
   |
47 |         uint256 totalRewardAmount,
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^

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

Ran 1 test for tests/security/Reentrancy.t.sol:ReentrancyTest
[PASS] test_TC23_ReentrancyOnUnstake() (gas: 436126)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 1.41ms (369.13µs CPU time)

Ran 8 tests for tests/unit/StandardStakingStrategy.t.sol:StandardStakingStrategyTest
[PASS] test_CalculateReward_FullPeriod() (gas: 54791)
[PASS] test_CalculateReward_NoOverlap() (gas: 52931)
[PASS] test_CalculateReward_NotEligible_AlreadyClaimed() (gas: 52595)
[PASS] test_CalculateReward_PartialPeriod_Start() (gas: 55440)
[PASS] test_CalculateReward_StakeEndsBeforePoolStarts() (gas: 53512)
[PASS] test_CalculateReward_StakeStartsAfterPoolEnds() (gas: 52908)
[PASS] test_CalculateReward_UnstakedDuringPool_NoReStakingAllowed() (gas: 53470)
[PASS] test_CalculateReward_ZeroTotalWeight() (gas: 52647)
Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 1.90ms (1.07ms CPU time)

Ran 6 tests for tests/unit/FullStakingStrategy.t.sol:FullStakingStrategyTest
[PASS] test_CalculateReward_Eligible_StakedEarlyHeldToEnd() (gas: 55316)
[PASS] test_CalculateReward_Eligible_StakedOnLastGraceDayHeldToEnd() (gas: 54111)
[PASS] test_CalculateReward_Eligible_UnstakedAfterEndDay() (gas: 54375)
[PASS] test_CalculateReward_NotEligible_AlreadyClaimed() (gas: 52381)
[PASS] test_CalculateReward_NotEligible_UnstakedOnEndDay() (gas: 53409)
[PASS] test_CalculateReward_ZeroTotalWeight() (gas: 52366)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 998.54µs (637.83µs CPU time)

Ran 5 tests for tests/unit/StrategiesRegistry.t.sol:StrategiesRegistryTest
[PASS] test_DisableStrategy_Fail_NotRegistered() (gas: 17486)
[PASS] test_RegisterAndGetStrategy() (gas: 115612)
[PASS] test_RegisterStrategy_Fail_NotManager() (gas: 19873)
[PASS] test_TC_SR01_DisableStrategy_Success() (gas: 94104)
[PASS] test_TC_SR02_EnableStrategy_Success() (gas: 148005)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 779.92µs (517.75µs CPU time)

Ran 2 tests for tests/unit/ClaimsJournal.t.sol:ClaimsJournalTest
[PASS] test_RecordClaim_ExclusiveBlocksAll() (gas: 81235)
[PASS] test_RecordClaim_SemiExclusiveLogic() (gas: 112241)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 3.14ms (318.75µs CPU time)

Ran 7 tests for tests/integration/TokenIntegration.t.sol:TokenIntegrationTest
[PASS] test_TC28_AllowanceChecks() (gas: 421658)
[PASS] test_TC28_BalanceValidation() (gas: 349678)
[PASS] test_TC28_ClaimContractTokenHandling() (gas: 385937)
[PASS] test_TC28_EmergencyTokenRecovery() (gas: 70491)
[PASS] test_TC28_SafeERC20Usage() (gas: 387524)
[PASS] test_TC28_TokenIntegration() (gas: 384546)
[PASS] test_TC28_TokenRelatedErrors() (gas: 345896)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 5.22ms (4.82ms CPU time)

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
Suite result: ok. 9 passed; 0 failed; 0 skipped; finished in 5.75ms (3.43ms CPU time)

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
Suite result: ok. 19 passed; 0 failed; 0 skipped; finished in 6.91ms (8.56ms CPU time)

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
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 4.37ms (5.35ms CPU time)

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
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 7.01ms (4.56ms CPU time)

Ran 11 tests for tests/unit/RewardManager.t.sol:RewardManagerTest
[PASS] test_AssignRewardToPool_Success() (gas: 97482)
[PASS] test_BatchClaimReward_Success() (gas: 311910)
[PASS] test_CalculateRewardsForPool() (gas: 194005)
[PASS] test_ClaimReward_Fail_IfAlreadyClaimed_DependentStrategy() (gas: 235153)
[PASS] test_ClaimReward_Fail_IfExclusiveClaimedOnLayer() (gas: 329343)
[PASS] test_ClaimReward_Success_DependentStrategy() (gas: 236966)
[PASS] test_ClaimReward_Success_IndependentStrategy() (gas: 204582)
[PASS] test_Pausable_AccessControl() (gas: 236393)
[PASS] test_TC_R23_SetClaimsJournal_Fail_IfNotAdmin() (gas: 1009313)
[PASS] test_TC_R23_SetClaimsJournal_Success() (gas: 1012398)
[PASS] test_TC_R24_BatchCalculateReward_HappyPath() (gas: 134890)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 7.19ms (7.01ms CPU time)

Ran 10 tests for tests/unit/FundingManager.t.sol:FundingManagerTest
[PASS] test_FundStrategy_Fail_AmountMustBeGreaterThanZero() (gas: 31959)
[PASS] test_FundStrategy_Fail_NotManager() (gas: 46766)
[PASS] test_FundStrategy_Fail_StrategyNotExist() (gas: 52320)
[PASS] test_FundStrategy_Success() (gas: 99107)
[PASS] test_TransferStrategyBalance_Fail_InsufficientBalance() (gas: 109117)
[PASS] test_TransferStrategyBalance_Fail_NotManager() (gas: 102220)
[PASS] test_TransferStrategyBalance_Success() (gas: 137208)
[PASS] test_WithdrawStrategy_Fail_InsufficientBalance() (gas: 101349)
[PASS] test_WithdrawStrategy_Fail_NotMultisig() (gas: 104542)
[PASS] test_WithdrawStrategy_Success() (gas: 146599)
Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 7.12ms (2.07ms CPU time)

Ran 35 tests for tests/unit/PoolManager.t.sol:PoolManagerTest
[PASS] test_GetLayerStrategies() (gas: 367123)
[PASS] test_GetPoolCount() (gas: 86352)
[PASS] test_GetPoolLayers() (gas: 453143)
[PASS] test_GetPools() (gas: 105602)
[PASS] test_GetPoolsByDateRange() (gas: 127356)
[PASS] test_GetStrategiesFromLayer() (gas: 702518)
[PASS] test_GetStrategyExclusivity() (gas: 244404)
[PASS] test_GetStrategyLayer() (gas: 243701)
[PASS] test_HasLayer() (gas: 248982)
[PASS] test_IsPoolActive() (gas: 60283)
[PASS] test_IsPoolCalculated() (gas: 90040)
[PASS] test_IsPoolEnded() (gas: 58503)
[PASS] test_MarkStrategyAsIgnored_Success() (gas: 309769)
[PASS] test_RemoveLayer_Fail_IfNotManager() (gas: 60294)
[PASS] test_RemoveLayer_Fail_IfPoolActive() (gas: 248006)
[PASS] test_RemoveLayer_Success() (gas: 208516)
[PASS] test_RemoveStrategyFromPool_Fail_IfNotManager() (gas: 250142)
[PASS] test_RemoveStrategyFromPool_Fail_IfPoolActive() (gas: 248363)
[PASS] test_RemoveStrategyFromPool_Success() (gas: 198899)
[PASS] test_RemoveStrategy_Fail_IfPoolAlreadyAnnounced() (gas: 248340)
[PASS] test_SetPoolLiveWeight_Fail_IfNotController() (gas: 60153)
[PASS] test_SetPoolLiveWeight_Success() (gas: 82413)
[PASS] test_SetPoolTotalStakeWeight_Fail_IfAlreadyCalculated() (gas: 89430)
[PASS] test_SetTotalStakeWeight_Fail_IfNotController() (gas: 60872)
[PASS] test_SetTotalStakeWeight_Fail_IfNotEnded() (gas: 59507)
[PASS] test_SetTotalStakeWeight_Success() (gas: 97609)
[PASS] test_TC_R22_GetPool_Fail_IfPoolDoesNotExist() (gas: 14395)
[PASS] test_UnmarkStrategyAsIgnored_Success() (gas: 254061)
[PASS] test_UpsertPool_Fail_IfPoolAlreadyStarted() (gas: 61095)
[PASS] test_UpsertPool_Fail_InvalidDates() (gas: 23184)
[PASS] test_UpsertPool_Fail_ParentPoolIsSelf() (gas: 55716)
[PASS] test_UpsertPool_Fail_PoolDoesNotExist() (gas: 19066)
[PASS] test_UpsertPool_Success() (gas: 81386)
[PASS] test_announcePool_Fail_IfNotManager() (gas: 59868)
[PASS] test_announcePool_Success() (gas: 64350)
Suite result: ok. 35 passed; 0 failed; 0 skipped; finished in 7.16ms (5.25ms CPU time)

Ran 13 test suites in 256.29ms (58.96ms CPU time): 135 tests passed, 0 failed, 0 skipped (135 total tests)

╭----------------------------------------------------------+------------------+------------------+-----------------+------------------╮
| File                                                     | % Lines          | % Statements     | % Branches      | % Funcs          |
+=====================================================================================================================================+
| src/StakingStorage.sol                                   | 91.27% (115/126) | 90.62% (116/128) | 61.54% (16/26)  | 86.96% (20/23)   |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/StakingVault.sol                                     | 92.50% (37/40)   | 89.19% (33/37)   | 80.00% (8/10)   | 88.89% (8/9)     |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/lib/Flags.sol                                        | 100.00% (6/6)    | 100.00% (7/7)    | 100.00% (0/0)   | 100.00% (3/3)    |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/reward-system/ClaimsJournal.sol                      | 100.00% (21/21)  | 100.00% (17/17)  | 90.91% (10/11)  | 100.00% (4/4)    |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/reward-system/FundingManager.sol                     | 100.00% (33/33)  | 100.00% (34/34)  | 87.50% (7/8)    | 100.00% (6/6)    |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/reward-system/PoolManager.sol                        | 98.26% (113/115) | 98.28% (114/116) | 100.00% (19/19) | 96.88% (31/32)   |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/reward-system/RewardManager.sol                      | 95.56% (86/90)   | 97.87% (92/94)   | 62.07% (18/29)  | 100.00% (17/17)  |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/reward-system/StrategiesRegistry.sol                 | 100.00% (29/29)  | 100.00% (28/28)  | 66.67% (4/6)    | 100.00% (8/8)    |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/reward-system/strategies/FullStakingStrategy.sol     | 88.24% (15/17)   | 93.75% (15/16)   | 100.00% (1/1)   | 80.00% (4/5)     |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| src/reward-system/strategies/StandardStakingStrategy.sol | 65.00% (13/20)   | 80.95% (17/21)   | 50.00% (1/2)    | 40.00% (2/5)     |
|----------------------------------------------------------+------------------+------------------+-----------------+------------------|
| Total                                                    | 94.16% (468/497) | 94.98% (473/498) | 75.00% (84/112) | 91.96% (103/112) |
╰----------------------------------------------------------+------------------+------------------+-----------------+------------------╯
