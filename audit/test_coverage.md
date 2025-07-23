Compiling 76 files with Solc 0.8.30
Solc 0.8.30 finished in 2.15s
Compiler run successful with warnings:
Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> src/reward-system/strategies/FullStakingStrategy.sol:44:9:
   |
44 |         address user,
   |         ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> src/reward-system/strategies/SimpleUserClaimableStrategy.sol:44:9:
   |
44 |         address user,
   |         ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> src/reward-system/strategies/StandardStakingStrategy.sol:44:9:
   |
44 |         address user,
   |         ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/FullStakingStrategy.t.sol:23:9:
   |
23 |         address _owner,
   |         ^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> tests/unit/StandardStakingStrategy.t.sol:22:9:
   |
22 |         address _owner,
   |         ^^^^^^^^^^^^^^

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

Warning (2018): Function state mutability can be restricted to view
   --> tests/unit/FullStakingStrategy.t.sol:126:5:
    |
126 |     function test_GetParameters() public {
    |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:49:5:
   |
49 |     function createStake(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:57:5:
   |
57 |     function removeStake(address, bytes32) external override {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:60:5:
   |
60 |     function isActiveStake(bytes32) external view override returns (bool) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:63:5:
   |
63 |     function getStakerInfo(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:68:5:
   |
68 |     function getStakerBalance(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:73:5:
   |
73 |     function getStakerBalanceAt(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:79:5:
   |
79 |     function batchGetStakerBalances(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:85:5:
   |
85 |     function getDailySnapshot(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:90:5:
   |
90 |     function getCurrentTotalStaked() external view override returns (uint128) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:93:5:
   |
93 |     function getTotalStakersCount() external view override returns (uint256) {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
  --> tests/unit/RewardManager.t.sol:96:5:
   |
96 |     function getStakersPaginated(
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
   --> tests/unit/RewardManager.t.sol:197:5:
    |
197 |     function stake(uint128, uint16) external override returns (bytes32) {
    |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to pure
   --> tests/unit/RewardManager.t.sol:200:5:
    |
200 |     function unstake(bytes32) external override {
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

Warning (2018): Function state mutability can be restricted to view
   --> tests/unit/StandardStakingStrategy.t.sol:118:5:
    |
118 |     function test_GetParameters() public {
    |     ^ (Relevant source part starts here and spans across multiple lines).

Analysing contracts...
Running tests...

Ran 1 test for tests/security/Reentrancy.t.sol:ReentrancyTest
[PASS] test_TC23_ReentrancyOnUnstake() (gas: 435768)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 12.51ms (1.80ms CPU time)

Ran 9 tests for tests/unit/FullStakingStrategy.t.sol:FullStakingStrategyTest
[PASS] test_CalculateReward_Eligible_StakedEarlyHeldToEnd() (gas: 52831)
[PASS] test_CalculateReward_Eligible_StakedOnLastGraceDayHeldToEnd() (gas: 52809)
[PASS] test_CalculateReward_Eligible_UnstakedAfterEndDay() (gas: 52839)
[PASS] test_CalculateReward_Eligible_UnstakedOnEndDay() (gas: 52882)
[PASS] test_CalculateReward_NotEligible_StakeEndsBeforeParentPool() (gas: 52857)
[PASS] test_CalculateReward_NotEligible_StakeStartsAfterParentPool() (gas: 52779)
[PASS] test_CalculateReward_NotEligible_StakedAfterGracePeriod() (gas: 52778)
[PASS] test_CalculateReward_NotEligible_UnstakedBeforeEnd() (gas: 52833)
[PASS] test_GetParameters() (gas: 16493)
Suite result: ok. 9 passed; 0 failed; 0 skipped; finished in 13.05ms (3.31ms CPU time)

Ran 10 tests for tests/unit/StandardStakingStrategy.t.sol:StandardStakingStrategyTest
[PASS] test_CalculateReward_FullPeriod() (gas: 53336)
[PASS] test_CalculateReward_NoOverlap() (gas: 52632)
[PASS] test_CalculateReward_PartialPeriod_End() (gas: 509030)
[PASS] test_CalculateReward_PartialPeriod_Middle() (gas: 509081)
[PASS] test_CalculateReward_PartialPeriod_Start() (gas: 53318)
[PASS] test_CalculateReward_StakeEndsBeforePoolStarts() (gas: 52611)
[PASS] test_CalculateReward_StakeStartsAfterPoolEnds() (gas: 52583)
[PASS] test_CalculateReward_UnstakedDuringPool_NoReStakingAllowed() (gas: 52592)
[PASS] test_CalculateReward_UnstakedDuringPool_ReStakingAllowed() (gas: 509053)
[PASS] test_GetParameters() (gas: 16514)
Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 13.20ms (3.44ms CPU time)

Ran 3 tests for tests/unit/RewardManager.t.sol:RewardManagerTest
[PASS] test_ClaimGrantedRewards_Success() (gas: 813830)
[PASS] test_ClaimImmediateAndRestake_Success() (gas: 911988)
[PASS] test_ClaimImmediateReward_Success() (gas: 883035)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 13.44ms (2.80ms CPU time)

Ran 9 tests for tests/unit/Flags.t.sol:FlagsTest
[PASS] test_TCF01_CheckFlagBitStatus() (gas: 25316)
[PASS] test_TCF01_SetFlagBit() (gas: 8402)
[PASS] test_TCF01_UnsetFlagBit() (gas: 7394)
[PASS] test_TCF02_MarkStakeAsFromClaim() (gas: 319658)
[PASS] test_TCF02_MultipleFlagCombinations() (gas: 6683)
[PASS] test_TCF02_RegularStakeFlagHandling() (gas: 354227)
[PASS] test_TCF03_AddNewFlagTypes() (gas: 6124)
[PASS] test_TCF03_FlagBoundaryConditions() (gas: 18204)
[PASS] test_TCF03_FlagPersistenceAndQueries() (gas: 449692)
Suite result: ok. 9 passed; 0 failed; 0 skipped; finished in 13.51ms (2.85ms CPU time)

Ran 7 tests for tests/integration/TokenIntegration.t.sol:TokenIntegrationTest
[PASS] test_TC28_AllowanceChecks() (gas: 420938)
[PASS] test_TC28_BalanceValidation() (gas: 349318)
[PASS] test_TC28_ClaimContractTokenHandling() (gas: 385556)
[PASS] test_TC28_EmergencyTokenRecovery() (gas: 16820)
[PASS] test_TC28_SafeERC20Usage() (gas: 387144)
[PASS] test_TC28_TokenIntegration() (gas: 384166)
[PASS] test_TC28_TokenRelatedErrors() (gas: 345536)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 14.21ms (3.66ms CPU time)

Ran 9 tests for tests/unit/PoolManager.t.sol:PoolManagerTest
[PASS] test_FinalizePool_Fail_NotEnded() (gas: 124259)
[PASS] test_FinalizePool_Success() (gas: 168614)
[PASS] test_UpdatePoolState_ActiveToEnded() (gas: 133389)
[PASS] test_UpdatePoolState_AnnouncedToActive() (gas: 127944)
[PASS] test_UpdatePoolState_Fail_AlreadyCalculated() (gas: 159461)
[PASS] test_UpsertPool_Fail_PoolIsActive() (gas: 132158)
[PASS] test_UpsertPool_Fail_StrategyIdZero() (gas: 17465)
[PASS] test_UpsertPool_NewPool_Success() (gas: 135530)
[PASS] test_UpsertPool_UpdateExisting_Success() (gas: 135921)
Suite result: ok. 9 passed; 0 failed; 0 skipped; finished in 14.24ms (4.70ms CPU time)

Ran 11 tests for tests/integration/VaultStorageIntegration.t.sol:VaultStorageIntegrationTest
[PASS] test_ComplexStakeAndUnstakeLifecycle() (gas: 721304)
[PASS] test_MultipleUsersIntegration() (gas: 598686)
[PASS] test_TC15_HistoricalDataConsistency() (gas: 684020)
[PASS] test_TC24_UnauthorizedStorageAccess() (gas: 316559)
[PASS] test_TC25_CheckpointCreationOnBalanceChange() (gas: 351298)
[PASS] test_TC27_CrossContractStateConsistency() (gas: 546233)
[PASS] test_TC27_VaultStorageCoordination() (gas: 448666)
[PASS] test_TC32_EventParameterVerification() (gas: 353779)
[PASS] test_TC3_TC19_ErrorHandlingIntegration() (gas: 366547)
[PASS] test_TC42_CrossContractEventCoordination() (gas: 370548)
[PASS] test_TC6_StakeFromClaimContract() (gas: 325401)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 14.96ms (6.27ms CPU time)

Ran 11 tests for tests/unit/StakingStorage.t.sol:StakingStorageTest
[PASS] test_TC13_GetStakeInformation() (gas: 355064)
[PASS] test_TC14_GetStakerInformation() (gas: 428734)
[PASS] test_TC15_HistoricalBalanceQueries() (gas: 680597)
[PASS] test_TC16_BatchHistoricalQueries() (gas: 841211)
[PASS] test_TC17_GlobalStatistics() (gas: 593669)
[PASS] test_TC18_StakerEnumeration() (gas: 846237)
[PASS] test_TC25_BasicDataIntegrity() (gas: 775591)
[PASS] test_TC26_VaultStorageIntegration() (gas: 383838)
[PASS] test_TC27_TokenIntegration() (gas: 377977)
[PASS] test_TC28_BasicTimeLockValidation() (gas: 377430)
[PASS] test_TC28_BasicTimeLockValidation_just1day() (gas: 384880)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 15.00ms (6.45ms CPU time)

Ran 19 tests for tests/unit/StakingVault.t.sol:StakingVaultTest
[PASS] test_TC10_FailedPauseUnauthorized() (gas: 14052)
[PASS] test_TC11_EmergencyTokenRecovery() (gas: 968405)
[PASS] test_TC12_EmergencyRecoverRole() (gas: 1087438)
[PASS] test_TC12_RoleManagement() (gas: 42567)
[PASS] test_TC19_InvalidStakeId() (gas: 26600)
[PASS] test_TC1_SuccessfulDirectStake() (gas: 374028)
[PASS] test_TC20_FailedUnstakeAlreadyUnstaked() (gas: 370299)
[PASS] test_TC22_PausedSystemOperations() (gas: 388705)
[PASS] test_TC23_ReentrancyProtection() (gas: 538175)
[PASS] test_TC24_AccessControlEnforcement() (gas: 30250)
[PASS] test_TC28_TokenIntegration() (gas: 384166)
[PASS] test_TC2_SuccessfulUnstaking() (gas: 388744)
[PASS] test_TC3_FailedUnstakingStakeNotMatured() (gas: 364101)
[PASS] test_TC4_SafeERC20BasicUsage() (gas: 371245)
[PASS] test_TC5_FailedStakingZeroAmount() (gas: 21004)
[PASS] test_TC6_StakeFromClaimContract() (gas: 326039)
[PASS] test_TC7_FailedClaimStakeUnauthorized() (gas: 20605)
[PASS] test_TC8_PauseSystem() (gas: 38909)
[PASS] test_TC9_UnpauseSystem() (gas: 29200)
Suite result: ok. 19 passed; 0 failed; 0 skipped; finished in 15.12ms (8.25ms CPU time)

Ran 10 test suites in 279.45ms (139.23ms CPU time): 89 tests passed, 0 failed, 0 skipped (89 total tests)

╭--------------------------------------------------------------+------------------+------------------+-----------------+-----------------╮
| File                                                         | % Lines          | % Statements     | % Branches      | % Funcs         |
+========================================================================================================================================+
| src/StakingStorage.sol                                       | 90.70% (117/129) | 90.15% (119/132) | 61.54% (16/26)  | 86.96% (20/23)  |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/StakingVault.sol                                         | 100.00% (38/38)  | 100.00% (34/34)  | 83.33% (10/12)  | 100.00% (8/8)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/lib/Flags.sol                                            | 100.00% (6/6)    | 100.00% (7/7)    | 100.00% (0/0)   | 100.00% (3/3)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/PoolManager.sol                            | 90.00% (36/40)   | 92.11% (35/38)   | 70.00% (14/20)  | 80.00% (4/5)    |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/RewardBookkeeper.sol                       | 44.44% (36/81)   | 44.79% (43/96)   | 18.18% (2/11)   | 36.36% (4/11)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/RewardManager.sol                          | 92.11% (70/76)   | 95.12% (78/82)   | 45.45% (10/22)  | 77.78% (7/9)    |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/StrategiesRegistry.sol                     | 60.00% (9/15)    | 54.55% (6/11)    | 25.00% (1/4)    | 60.00% (3/5)    |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/strategies/FullStakingStrategy.sol         | 100.00% (11/11)  | 100.00% (12/12)  | 100.00% (1/1)   | 100.00% (3/3)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/strategies/SimpleUserClaimableStrategy.sol | 0.00% (0/15)     | 0.00% (0/18)     | 0.00% (0/2)     | 0.00% (0/3)     |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| src/reward-system/strategies/StandardStakingStrategy.sol     | 100.00% (15/15)  | 100.00% (20/20)  | 100.00% (3/3)   | 100.00% (3/3)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| tests/security/Reentrancy.t.sol                              | 90.00% (9/10)    | 77.78% (7/9)     | 100.00% (1/1)   | 100.00% (4/4)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| tests/unit/FullStakingStrategy.t.sol                         | 14.29% (4/28)    | 14.29% (2/14)    | 100.00% (0/0)   | 14.29% (2/14)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| tests/unit/RewardManager.t.sol                               | 50.00% (28/56)   | 62.16% (23/37)   | 66.67% (2/3)    | 36.36% (8/22)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| tests/unit/StandardStakingStrategy.t.sol                     | 14.29% (4/28)    | 14.29% (2/14)    | 100.00% (0/0)   | 14.29% (2/14)   |
|--------------------------------------------------------------+------------------+------------------+-----------------+-----------------|
| Total                                                        | 69.89% (383/548) | 74.05% (388/524) | 57.14% (60/105) | 55.91% (71/127) |
╰--------------------------------------------------------------+------------------+------------------+-----------------+-----------------╯
