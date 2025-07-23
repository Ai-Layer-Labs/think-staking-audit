# Token Staking System: Architecture Overview

## System Architecture

The Token staking system features a modular architecture with clear separation of concerns across core staking functionality and reward management. The design emphasizes security, gas efficiency, and maintainability while supporting both immediate and epoch-based reward strategies.

### Core Components

#### 1. Staking Core System

##### StakingVault (Business Logic Layer)

**Location**: `src/StakingVault.sol`
**Role**: Primary interface contract that handles all user interactions and business logic.

**Key Responsibilities**:

- **Token Management**: Handles IERC20 token transfers (deposits/withdrawals)
- **Stake Operations**: Creates and processes stake/unstake requests with compound stakeId generation
- **Time Lock Enforcement**: Validates stake maturity before allowing unstaking
- **Access Control**: Role-based permissions (Admin, Manager, Claim Contract)
- **Security**: Reentrancy protection, pause mechanism, emergency controls

##### StakingStorage (Data Persistence Layer)

**Location**: `src/StakingStorage.sol`
**Role**: Dedicated storage contract that maintains all staking data and historical records.

**Key Responsibilities**:

- **Compound StakeId Management**: Generates unique stake identifiers using address + counter
- **Stake Flags System**: Extensible `uint16 flags` field for multiple boolean properties
- **Historical Data**: Maintains comprehensive checkpoint system with O(log n) queries
- **Balance Tracking**: Real-time and historical balance calculations
- **Global Statistics**: Network-wide staking metrics and daily snapshots

#### 2. Reward Management System

##### PoolManager (Lifecycle & State Management)

**Location**: `src/reward-system/PoolManager.sol`
**Role**: The single source of truth for defining and managing the lifecycle of all `ADMIN_GRANTED` reward pools.

**Key Responsibilities**:
- **Pool Definition**: Creates pools with a `startDay`, `endDay`, and an associated `strategyId`.
- **State Machine**: Manages the state of each pool through its lifecycle: `ANNOUNCED` -> `ACTIVE` -> `ENDED` -> `CALCULATED`.
- **Finalization**: Stores the final `totalStakeWeight` for a calculated pool, which is used by off-chain services to determine individual user rewards.

##### StrategiesRegistry (Strategy Directory)
**Location**: `src/reward-system/StrategiesRegistry.sol`
**Role**: A simple registry that maps a `bytes32` strategy ID to a deployed strategy contract address.

##### RewardBookkeeper (Ledger for Granted Rewards)

**Location**: `src/reward-system/RewardBookkeeper.sol`
**Role**: Acts as the definitive ledger for all `ADMIN_GRANTED` rewards. It stores pre-calculated reward amounts for each user from finalized pools.

##### RewardManager (Orchestration Layer)

**Location**: `src/reward-system/RewardManager.sol`
**Role**: The central user-facing contract for all reward claims. It orchestrates payments for two distinct reward models.

**Key Features**:
- **Dual Claim Models**: Provides separate, optimized functions for claiming `ADMIN_GRANTED` (pool-based) and `USER_CLAIMABLE` (immediate) rewards.
- **Funding Management**: Manages funding for `PRE_FUNDED` immediate strategies.
- **Interaction with RewardBookkeeper**: For granted rewards, it verifies the user's entitlement with the `RewardBookkeeper` contract, executes the payment, and updates the bookkeeper to mark the reward as claimed.
- **On-Demand Calculations**: For immediate rewards, it calculates the reward amount on-the-fly based on the strategy's logic and the user's staking history.


#### 3. Interface Architecture

##### Organized Interface Structure

```
src/interfaces/
├── staking/
│   ├── IStakingStorage.sol    # Core staking data interface
│   └── StakingErrors.sol      # Staking error definitions
└── reward/
    ├── RewardEnums.sol        # Shared enumerations
    ├── RewardErrors.sol       # Standardized error definitions
    ├── IRewardStrategy.sol
    └── IRewardManager.sol     # RewardManager interface and events
```

##### Advanced Data Structures

**Compound StakeId System**:

```solidity
// 256-bit stakeId: [160-bit address][96-bit counter]
function _generateStakeId(address staker, uint32 counter) internal pure returns (bytes32) {
    return bytes32((uint256(uint160(staker)) << 96) | counter);
}
```

**Extensible Flag System**:

```solidity
struct Stake {
    uint128 amount;
    uint16 stakeDay;
    uint16 unstakeDay;
    uint16 daysLock;
    uint16 flags;  // Supports 16 boolean properties
}
```

**Checkpoint System**: Binary search optimization for historical balance queries.

### Data Flow Architecture

#### Staking Flow
```
User Transaction
       ↓
StakingVault (validates & processes)
       ↓
StakingStorage (persists & tracks)
       ↓
Checkpoint System (historical record)
       ↓
Event Emission (transparency)
```

#### Reward Claim Flows

**1. Granted Rewards (`claimGrantedRewards`)**
```mermaid
sequenceDiagram
    participant User
    participant RewardManager
    participant RewardBookkeeper
    participant ERC20

    User->>+RewardManager: claimGrantedRewards()
    RewardManager->>+RewardBookkeeper: getUserClaimableRewards(User)
    RewardBookkeeper-->>-RewardManager: returns rewards[], indices[]
    Note over RewardManager: Aggregates total amount
    RewardManager->>+ERC20: safeTransfer(User, totalAmount)
    ERC20-->>-RewardManager: (tokens transferred)
    RewardManager->>+RewardBookkeeper: batchMarkClaimed(User, indices)
    RewardBookkeeper-->>-RewardManager: (state updated)
    RewardManager-->>-User: (claim complete)
```

**2. Immediate Rewards (`claimImmediateReward`)**
```mermaid
sequenceDiagram
    participant User
    participant RewardManager
    participant IRewardStrategy
    participant ERC20

    User->>+RewardManager: claimImmediateReward(strategyId, stakeId)
    RewardManager->>+IRewardStrategy: calculateReward(user, stake, start, end)
    IRewardStrategy-->>-RewardManager: returns rewardAmount
    Note over RewardManager: Checks funding (balances/treasury)
    RewardManager->>+ERC20: safeTransfer(User, rewardAmount)
    ERC20-->>-RewardManager: (tokens transferred)
    Note over RewardManager: Updates claim timestamps
    RewardManager-->>-User: returns rewardAmount
```

### Storage Design Patterns

#### Checkpoint System

The storage contract implements a sophisticated checkpoint mechanism that automatically records balance changes:

- **Automatic Snapshots**: Every stake/unstake creates a checkpoint
- **Binary Search Optimization**: Efficient historical balance queries
- **Gas Efficiency**: Minimizes storage operations while maximizing data availability
- **Historical Integrity**: Immutable record of all balance changes

#### Stake Lifecycle Management

Each stake follows a complete lifecycle with full traceability:

1. **Creation**: Unique ID generation, initial checkpoint
2. **Active Period**: Continuous balance tracking
3. **Maturation**: Time lock validation
4. **Completion**: Unstaking with final checkpoint

### Security Architecture

#### Multi-Layer Security

- **Role-Based Access Control**: Different permission levels for different operations
- **Reentrancy Protection**: Guards against recursive call attacks
- **Pause Mechanism**: Emergency system shutdown capability
- **Time Lock Enforcement**: Immutable stake duration requirements
- **Emergency Recovery**: A feature controlled by a dedicated `MULTISIG_ROLE` to recover any ERC20 tokens accidentally sent to the contract. This prevents loss of funds while ensuring the action is controlled by a secure, multi-signature entity, separate from the general admin role.

#### Separation of Concerns

- **StakingVault**: Handles external interactions and security checks
- **StakingStorage**: Manages data integrity and historical records
- **RewardManager**: Orchestrates reward payments and funding.
- **RewardBookkeeper**: Securely ledgers all granted rewards.
- **Clear Boundaries**: Minimizes attack surface through modular design.

## Integration Architecture

### Current System Integration

#### Token Integration

- **IERC20 Compatibility**: Works with any standard ERC20 token
- **SafeERC20 Usage**: Protection against non-standard token implementations
- **Immutable Token Reference**: Prevents token switching attacks

#### Claim Contract Integration

- **Dedicated Role**: `CLAIM_CONTRACT_ROLE` for external claiming systems
- **Flexible Staking**: Supports staking on behalf of users
- **Claim Marking**: Distinguishes between direct stakes and claim-originated stakes

### Future Integration Points

#### Reward System Integration

The current architecture is designed to seamlessly integrate with the upcoming reward system:

- **Historical Data Ready**: Checkpoint system provides all necessary historical data
- **Reward Calculator Interface**: Storage contract exposes all required data points
- **Efficient Queries**: Optimized for reward calculation workloads

#### External Protocol Integration

- **Modular Design**: Easy integration with other DeFi protocols
- **Event-Driven Architecture**: External systems can monitor via events
- **Standardized Interfaces**: Follows common DeFi integration patterns

## Technical Specifications

### Smart Contract Details

#### StakingVault

- **Inheritance**: ReentrancyGuard, AccessControl, Pausable
- **Key Functions**: `stake()`, `unstake()`, `stakeFromClaim()`
- **Access Roles**: `DEFAULT_ADMIN_ROLE`, `MANAGER_ROLE`, `CLAIM_CONTRACT_ROLE`
- **Gas Optimization**: Minimal external calls, efficient validation

#### StakingStorage

- **Inheritance**: AccessControl
- **Key Functions**: `createStake()`, `removeStake()`, `getStakerBalanceAt()`
- **Access Roles**: `DEFAULT_ADMIN_ROLE`, `MANAGER_ROLE`, `CONTROLLER_ROLE`
- **Data Optimization**: Binary search, paginated queries, efficient mappings

### Performance Characteristics

#### Gas Efficiency

- **Staking**: ~150,000 gas (including token transfer)
- **Unstaking**: ~120,000 gas (including token transfer)
- **Balance Queries**: ~15,000 gas (binary search optimization)
- **Batch Operations**: Optimized for multiple stakes

#### Scalability

- **Concurrent Users**: Supports unlimited concurrent stakers
- **Historical Data**: Efficient storage and retrieval of historical balances
- **Large Datasets**: Paginated access to staker lists and historical data

## Deployment Architecture

### Contract Deployment Order

1. **Token Contract**: Deploy or use existing IERC20 token
2. **StakingStorage**: Deploy with admin and manager roles.
3. **StakingVault**: Deploy with token and storage references.
4. **RewardBookkeeper**: Deploy with admin and manager roles.
5. **RewardManager**: Deploy with all necessary contract references.
6. **Role Configuration**: Set up all `CONTROLLER_ROLE` and other cross-contract permissions.
7. **Testing**: Comprehensive integration testing.

### Configuration Management

- **Immutable References**: Core contract addresses cannot be changed
- **Role Management**: Flexible role assignment for operational needs
- **Emergency Controls**: Pause and emergency recovery mechanisms

## Monitoring and Observability

### Event Architecture

Comprehensive event emission for complete system transparency:

- **Stake Events**: Full stake creation details
- **Unstake Events**: Complete unstaking information
- **Checkpoint Events**: Historical data tracking
- **Reward Events**: Detailed events for both granted and immediate claims.
- **Administrative Events**: Role changes and system state updates

### Analytics Support

- **Daily Snapshots**: Network-wide statistics
- **Historical Queries**: Complete historical balance data
- **Staker Analytics**: Individual and aggregate staking metrics
- **Integration Points**: Data export capabilities for external analytics

## Upgrade and Maintenance Strategy

### Immutable Core

- **Core Logic**: StakingVault and StakingStorage are immutable once deployed
- **Data Integrity**: Historical data cannot be modified or lost
- **Security**: Eliminates upgrade-related attack vectors

### Extensibility

- **Modular Design**: New features can be added through additional contracts
- **Integration Layers**: External contracts can build on top of the core system
- **Backward Compatibility**: Future enhancements maintain compatibility

---

This architecture provides a robust foundation, with careful attention to security, efficiency, and future extensibility. The separation between business logic and data storage ensures that the system can evolve while maintaining data integrity and user trust.
