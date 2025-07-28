# Token Staking System: Test Coverage Matrix

## Overview

This matrix maps use cases to test cases and functions, ensuring practical coverage of the Token Staking System. It provides traceability from requirements through implementation to testing for both core staking and the rewards system.

**Scope**: This document covers the entire system, including core staking contracts (`StakingVault`, `StakingStorage`) and the reward management system (`PoolManager`, `StrategiesRegistry`, `RewardManager`, `ClaimsJournal`, and strategy implementations).

## Use Case to Test Cases Mapping

| Use Case ID  | Description                            | Test Cases                                     |
| :----------- | :------------------------------------- | :--------------------------------------------- |
| **UC1-UC20** | _Core Staking, Roles, and Integration_ | TC1-TC28, TC_F01-F03                           |
| **UC21**     | **Pool and Strategy Configuration**    | TC_R01, TC_R02                                 |
| **UC22**     | **Pool Finalization**                  | TC_R03                                         |
| **UC23**     | **Unified Reward Claiming**            | TC_R04, TC_R05, TC_R06, TC_R07, TC_R08, TC_R10 |
| **UC24**     | **Reward Funding**                     | TC_R09                                         |

## Function to Test Cases Matrix

### Core Staking Contracts (Largely Unchanged)

| Contract                                 | Function                 | Required Test Cases        |
| :--------------------------------------- | :----------------------- | :------------------------- |
| **StakingVault**                         | `stake(uint128, uint16)` | TC1, TC4, TC5, TC22, TC23  |
| **StakingVault**                         | `unstake(bytes32)`       | TC2, TC3, TC22, TC23       |
| **StakingStorage**                       | `createStake(...)`       | TC1, TC6, TC24, TC25, TC26 |
| **StakingStorage**                       | `removeStake(...)`       | TC2, TC24, TC25, TC26      |
| _... (other core staking functions) ..._ | _..._                    | _..._                      |

### Reward System Contracts

| Contract                    | Function                       | Required Test Cases                    |
| :-------------------------- | :----------------------------- | :------------------------------------- |
| **PoolManager**             | `upsertPool(...)`              | TC_R01                                 |
| **PoolManager**             | `assignStrategyToPool(...)`    | TC_R02                                 |
| **PoolManager**             | `setPoolTotalStakeWeight(...)` | TC_R03                                 |
| **StrategiesRegistry**      | `registerStrategy(...)`        | TC_R01 (from use cases)                |
| **RewardManager**           | `fundStrategy(...)`            | TC_R09                                 |
| **RewardManager**           | `claimReward(...)`             | TC_R04, TC_R05, TC_R06, TC_R07, TC_R08 |
| **RewardManager**           | `getClaimableReward(...)`      | TC_R10                                 |
| **RewardManager**           | `setClaimsJournal(...)`        | (Deployment/Test Setup)                |
| **ClaimsJournal**           | `recordClaim(...)`             | TC_R04, TC_R05                         |
| **ClaimsJournal**           | `getLastClaimDay(...)`         | TC_R04, TC_R05                         |
| **ClaimsJournal**           | `getLayerClaimState(...)`      | TC_R08                                 |
| **FullStakingStrategy**     | `calculateReward(...)`         | (Strategy-specific tests)              |
| **StandardStakingStrategy** | `calculateReward(...)`         | (Strategy-specific tests)              |

## Gap Analysis

### Investigation Workflow

1.  **Check forge coverage**: `forge coverage --report summary`
2.  **Find uncovered functions** in the coverage report.
3.  **Look up required test cases** in the "Function to Test Cases Matrix" above.
4.  **Implement missing tests** if any gaps are found.
