// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IEnums {
    enum StrategyType {
        IMMEDIATE, // Can calculate anytime (APR-style)
        EPOCH_BASED // Fixed pools after epoch ends
    }

    enum PoolState {
        UNINITIALIZED, // Default state
        ANNOUNCED, // Rules published, users can prepare
        ACTIVE, // Pool running, tracking participants
        ENDED, // Finished, awaiting admin calculation
        CALCULATED // Rewards calculated, ready for granting
    }
}
