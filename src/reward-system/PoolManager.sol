// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/reward/IEnums.sol";
import "../interfaces/reward/RewardErrors.sol";

/**
 * @title PoolManager
 * @author @Tudmotu
 * @notice Manages the lifecycle and hierarchy of all reward pools (epochs).
 * @dev This contract is the single source of truth for reward period definitions and state.
 */
contract PoolManager is IEnums, AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    struct Pool {
        uint32 id;
        uint16 startDay;
        uint16 endDay;
        uint32 strategyId;
        uint32 parentId;
    }

    mapping(uint32 => Pool) public pools;
    mapping(uint32 => PoolState) public poolState;
    mapping(uint32 => uint256) public poolTotalStakeWeight;
    mapping(uint32 => uint256) public poolLiveStakeWeight;

    uint32 public nextPoolId = 1;

    event PoolUpserted(
        uint32 indexed poolId,
        uint16 startDay,
        uint16 endDay,
        uint32 indexed parentId,
        uint32 indexed strategyId
    );
    event PoolStateChanged(uint32 indexed poolId, PoolState newState);
    event PoolFinalized(uint32 indexed poolId, uint256 totalStakeWeight);
    event PoolLiveStakeWeightUpdated(
        uint32 indexed poolId,
        uint256 liveStakeWeight
    );

    constructor(address _admin, address _manager) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MANAGER_ROLE, _manager);
    }

    function upsertPool(
        uint32 _poolId,
        uint16 _startDay,
        uint16 _endDay,
        uint32 _parentId,
        uint32 _strategyId
    ) external onlyRole(MANAGER_ROLE) returns (uint32) {
        require(_startDay < _endDay, RewardErrors.InvalidPoolDates());
        if (_parentId != 0) {
            require(
                pools[_parentId].id != 0,
                RewardErrors.PoolDoesNotExist(_parentId)
            );
        }
        require(
            _strategyId != 0,
            RewardErrors.StrategyNotRegistered(_strategyId)
        );

        uint32 poolIdToUpdate = _poolId == 0 ? nextPoolId : _poolId;
        require(
            poolState[poolIdToUpdate] == PoolState.UNINITIALIZED ||
                poolState[poolIdToUpdate] == PoolState.ANNOUNCED,
            RewardErrors.PoolAlreadyActiveOrFinalized(poolIdToUpdate)
        );

        pools[poolIdToUpdate] = Pool({
            id: poolIdToUpdate,
            startDay: _startDay,
            endDay: _endDay,
            parentId: _parentId,
            strategyId: _strategyId
        });

        if (poolState[poolIdToUpdate] == PoolState.UNINITIALIZED) {
            poolState[poolIdToUpdate] = PoolState.ANNOUNCED;
        }

        if (_poolId == 0) {
            nextPoolId++;
        }

        emit PoolUpserted(
            poolIdToUpdate,
            _startDay,
            _endDay,
            _parentId,
            _strategyId
        );
        emit PoolStateChanged(poolIdToUpdate, poolState[poolIdToUpdate]);
        return poolIdToUpdate;
    }

    function updatePoolState(uint32 _poolId) external {
        PoolState currentState = poolState[_poolId];
        require(
            currentState != PoolState.UNINITIALIZED &&
                currentState != PoolState.CALCULATED,
            RewardErrors.PoolNotInitializedOrCalculated(_poolId)
        );

        uint16 currentDay = uint16(block.timestamp / 1 days);
        Pool memory pool = pools[_poolId];

        if (
            currentState == PoolState.ANNOUNCED && currentDay >= pool.startDay
        ) {
            poolState[_poolId] = PoolState.ACTIVE;
            emit PoolStateChanged(_poolId, PoolState.ACTIVE);
        } else if (
            currentState == PoolState.ACTIVE && currentDay > pool.endDay
        ) {
            poolState[_poolId] = PoolState.ENDED;
            emit PoolStateChanged(_poolId, PoolState.ENDED);
        }
    }

    function updatePoolLiveStakeWeight(
        uint32 _poolId,
        uint256 _liveStakeWeight
    ) external onlyRole(MANAGER_ROLE) {
        require(
            poolState[_poolId] < PoolState.CALCULATED,
            RewardErrors.PoolAlreadyCalculated(_poolId)
        );
        poolLiveStakeWeight[_poolId] = _liveStakeWeight;
        emit PoolLiveStakeWeightUpdated(_poolId, _liveStakeWeight);
    }

    /**
     * @notice Finalizes a pool and locks in the official total stake weight for reward calculations.
     * @dev This is the point of no return. After this, the total stake weight cannot be changed.
     * @param _poolId The ID of the pool to finalize.
     * @param _finalStakeWeight The official, verified total stake weight to be used for all reward calculations.
     */
    function finalizePool(
        uint32 _poolId,
        uint256 _finalStakeWeight
    ) external onlyRole(MANAGER_ROLE) {
        require(
            poolState[_poolId] == PoolState.ENDED,
            RewardErrors.PoolNotEnded(_poolId)
        );

        poolTotalStakeWeight[_poolId] = _finalStakeWeight;
        poolState[_poolId] = PoolState.CALCULATED;

        emit PoolFinalized(_poolId, _finalStakeWeight);
        emit PoolStateChanged(_poolId, PoolState.CALCULATED);
    }

    function getPool(uint32 _poolId) external view returns (Pool memory) {
        require(pools[_poolId].id != 0, RewardErrors.PoolDoesNotExist(_poolId));
        return pools[_poolId];
    }
}
