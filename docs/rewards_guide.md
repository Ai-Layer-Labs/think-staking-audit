# Token Rewards System: A Guide

## Overview

The THINK ecosystem features a comprehensive rewards system that works seamlessly with the staking mechanism to provide sophisticated earning opportunities for token holders. The system is designed to be flexible, supporting different types of reward strategies.

## Two Ways to Earn Rewards

The system offers two distinct models for earning and claiming rewards.

### 1. Granted Rewards (Pool-Based)

This model is used for strategies tied to specific time periods, like monthly epochs or quarterly cycles. These are often special, one-time reward pools.

-   **How it Works:** An administrative process calculates rewards for all eligible stakers *after* a reward period (a "Pool") has ended. These calculated amounts are then recorded on-chain in a secure ledger contract (`RewardBookkeeper`).
-   **Claiming:** Once your reward is granted, it appears as a "claimable balance." You can then call the `claimGrantedRewards()` function to receive all your available granted rewards in a single, gas-efficient transaction.
-   **Use Case:** Perfect for distributing a fixed pool of tokens to users based on their participation over a specific period (e.g., a 90-day "Early Staker Bonus" pool).

### 2. Immediate Rewards (APR-Style)

This model is used for dynamic strategies, like those based on a variable Annual Percentage Rate (APR), where rewards accrue continuously based on the number of full days you have staked.

-   **How it Works:** There is no pre-calculation. When you decide to claim, the `claimImmediateReward()` function calculates your earnings on-the-fly based on your stake amount and the number of full, completed days since your last claim for that strategy.
-   **Claiming:** You can call `claimImmediateReward()` at any time to calculate and receive your accrued rewards. You can also use `claimImmediateAndRestake()` to compound your earnings back into a new stake.
-   **Use Case:** Ideal for flexible, APR-style rewards that are not tied to a fixed pool or epoch.

## How Staking Data Powers Rewards

The reward system is built directly on top of the staking system's data.

#### Day-Based Calculations

The core of the system's fairness comes from its use of **days** as the unit for all calculations.
-   When you stake, the system records the `stakeDay`.
-   All reward calculations, for both Granted and Immediate rewards, are based on the number of full days your stake has been active.
-   This ensures that rewards are predictable and not affected by the specific time of day you stake or claim.

#### Checkpoints

The staking system uses automatic "snapshots" called checkpoints every time you stake or unstake. This provides a secure and efficient way for the reward system to access your historical staking data, ensuring all calculations are accurate and fair.

## Getting Started

To begin earning rewards, simply stake your tokens. Your active stakes will automatically be eligible for any reward strategies that are running. Monitor the project's official announcements to learn about new reward pools and strategies as they become available.
