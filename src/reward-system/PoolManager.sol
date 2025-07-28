// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract PoolManager is AccessControl {
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");

    enum StrategyExclusivity {
        NORMAL, // can be combined with any other
        EXCLUSIVE, // excludes all other on the layer
        SEMI_EXCLUSIVE // excludes only other SEMI_EXCLUSIVE and EXCLUSIVE
    }

    struct Pool {
        uint16 startDay;
        uint16 endDay;
        uint256 totalPoolWeight;
        uint256 parentPoolId;
    }

    uint256 public nextPoolId;

    mapping(uint256 poolId => Pool) public pools;
    // poolLiveWeight is used to calculate the preliminary rewards for the pool
    mapping(uint256 poolId => uint256) public poolLiveWeight;
    mapping(uint256 poolId => mapping(uint8 layer => uint32[] strategies))
        public poolLayerStrategies;

    mapping(uint32 strategyId => StrategyExclusivity) public exclusivity;
    mapping(uint256 poolId => EnumerableSet.UintSet) internal _poolLayers;

    // Cache for quick search of strategy layer
    mapping(uint256 poolId => mapping(uint32 strategyId => uint8))
        public strategyLayer;

    event PoolUpserted(
        uint256 indexed poolId,
        uint16 startDay,
        uint16 endDay,
        uint256 totalPoolWeight,
        uint256 indexed parentPoolId
    );
    event StrategyAddedToLayer(uint32 poolId, uint8 layer, uint32 strategyId);
    event StrategyRemovedFromLayer(
        uint256 indexed poolId,
        uint8 layer,
        uint32 strategyId
    );

    error PoolAlreadyStarted();
    error PoolNotEnded();
    error PoolAlreadyCalculated();
    error InvalidDates();
    error ParentPoolIsSelf();

    constructor(address admin, address manager, address controller) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MANAGER_ROLE, manager);
        _grantRole(CONTROLLER_ROLE, controller);
        nextPoolId = 1;
    }

    /** ------------------------------------------------
     *  ! Pool Management
     * ------------------------------------------------ */

    function upsertPool(
        uint256 _poolId,
        uint16 _startDay,
        uint16 _endDay,
        uint256 _parentPoolId
    ) external onlyRole(MANAGER_ROLE) returns (uint256 poolId) {
        poolId = _poolId == 0 ? nextPoolId++ : _poolId;

        require(_parentPoolId != poolId, ParentPoolIsSelf());
        require(_startDay < _endDay, InvalidDates());
        require(!_isStarted(poolId), PoolAlreadyStarted());

        Pool storage p = pools[poolId];
        p.startDay = _startDay;
        p.endDay = _endDay;
        p.parentPoolId = _parentPoolId;

        emit PoolUpserted(poolId, p.startDay, p.endDay, 0, p.parentPoolId);
    }

    function setPoolTotalStakeWeight(
        uint256 poolId,
        uint256 totalPoolWeight
    ) external onlyRole(CONTROLLER_ROLE) {
        if (!_isEnded(poolId)) revert PoolNotEnded();
        if (_isCalculated(poolId)) revert PoolAlreadyCalculated();

        Pool storage p = pools[poolId];

        p.totalPoolWeight = totalPoolWeight;
        emit PoolUpserted(
            poolId,
            p.startDay,
            p.endDay,
            p.totalPoolWeight,
            p.parentPoolId
        );
    }

    function setPoolLiveWeight(
        uint256 poolId,
        uint256 liveWeight
    ) external onlyRole(CONTROLLER_ROLE) {
        poolLiveWeight[poolId] = liveWeight;
    }

    /**
     * Assigns a strategy to a pool layer.
     * @notice The strategy can be assigned even to an active or calculated pool, retroactively
     * @param poolId The ID of the pool to assign the strategy to.
     * @param layer The layer to assign the strategy to.
     * @param strategyId The ID of the strategy to assign.
     * @param strategyExclusivity The exclusivity of the strategy.
     */
    function assignStrategyToPool(
        uint256 poolId,
        uint8 layer,
        uint32 strategyId,
        StrategyExclusivity strategyExclusivity
    ) external onlyRole(MANAGER_ROLE) {
        if (_isActive(poolId)) revert PoolAlreadyStarted();

        _poolLayers[poolId].add(layer);
        poolLayerStrategies[poolId][layer].push(strategyId);
        exclusivity[strategyId] = strategyExclusivity;
        strategyLayer[poolId][strategyId] = layer;
    }

    function removeLayer(
        uint256 poolId,
        uint8 layer
    ) external onlyRole(MANAGER_ROLE) {
        if (_isActive(poolId)) revert PoolAlreadyStarted();
        _poolLayers[poolId].remove(layer);
    }

    function removeStrategyFromPool(
        uint256 poolId,
        uint8 layer,
        uint32 strategyId
    ) external onlyRole(MANAGER_ROLE) {
        if (_isActive(poolId)) revert PoolAlreadyStarted();

        delete strategyLayer[poolId][strategyId];
        delete exclusivity[strategyId];

        uint32[] storage strategies = poolLayerStrategies[poolId][layer];
        for (uint256 i = 0; i < strategies.length; i++) {
            if (strategies[i] == strategyId) {
                strategies[i] = strategies[strategies.length - 1];
                strategies.pop();
                break;
            }
        }
        emit StrategyRemovedFromLayer(poolId, layer, strategyId);
    }

    /** ------------------------------------------------
     *  ! Getters
     * ------------------------------------------------ */

    // function isClaimable(
    //     uint256 poolId,
    //     uint32 strategyId
    // ) external view returns (bool canClaim) {
    //     uint8 layer = strategyLayer[poolId][strategyId];
    //     StrategyType targetType = strategyTypes[strategyId];

    //     // Check if there are any exclusive or semi-exclusive strategies on the layer
    //     bool hasExclusive = false;
    //     bool hasSemiExclusive = false;
    //     bool hasTargetStrategy = false;

    //     for (uint256 i = 0; i < activeStrategiesOnLayer.length; i++) {
    //         uint256 activeStrategyId = activeStrategiesOnLayer[i];
    //         StrategyType activeType = strategyTypes[activeStrategyId];

    //         if (activeStrategyId == strategyId) {
    //             hasTargetStrategy = true;
    //             continue;
    //         }

    //         if (activeType == StrategyType.EXCLUSIVE) {
    //             hasExclusive = true;
    //         } else if (activeType == StrategyType.SEMI_EXCLUSIVE) {
    //             hasSemiExclusive = true;
    //         }
    //     }

    //     // Validation logic
    //     if (targetType == StrategyType.NORMAL) {
    //         // NORMAL can only work if there is no EXCLUSIVE
    //         return !hasExclusive && hasTargetStrategy;
    //     }

    //     if (targetType == StrategyType.EXCLUSIVE) {
    //         // EXCLUSIVE can only work if it is the only active strategy on the layer
    //         return hasTargetStrategy && activeStrategiesOnLayer.length == 1;
    //     }

    //     if (targetType == StrategyType.SEMI_EXCLUSIVE) {
    //         // SEMI_EXCLUSIVE can only work with EXCLUSIVE or other SEMI_EXCLUSIVE
    //         return hasTargetStrategy && !hasExclusive && !hasSemiExclusive;
    //     }

    //     return false;
    // }

    function getStrategyLayer(
        uint256 poolId,
        uint32 strategyId
    ) external view returns (uint8) {
        return strategyLayer[poolId][strategyId];
    }

    function getStrategyExclusivity(
        uint32 strategyId
    ) external view returns (StrategyExclusivity) {
        return exclusivity[strategyId];
    }

    function getLayerStrategies(
        uint256 poolId,
        uint8 layer
    ) external view returns (uint32[] memory) {
        return poolLayerStrategies[poolId][layer];
    }

    function hasLayer(
        uint256 poolId,
        uint8 layer
    ) external view returns (bool) {
        return _poolLayers[poolId].contains(layer);
    }

    function getPoolsByDateRange(
        uint16 _fromDay,
        uint16 _toDay
    ) external view returns (uint256[] memory) {
        // This can be gas-intensive if there are many pools.
        uint256[] memory tempPools = new uint256[](nextPoolId - 1);
        uint256 count = 0;
        for (uint256 i = 1; i < nextPoolId; i++) {
            if (pools[i].startDay <= _toDay && pools[i].endDay >= _fromDay) {
                tempPools[count] = i;
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = tempPools[i];
        }
        return result;
    }

    function getPool(uint256 poolId) external view returns (Pool memory) {
        return pools[poolId];
    }

    function getPools(
        uint256[] memory poolIds
    ) external view returns (Pool[] memory result) {
        result = new Pool[](poolIds.length);
        for (uint256 i = 0; i < poolIds.length; i++) {
            result[i] = pools[poolIds[i]];
        }
    }
    function getPoolCount() external view returns (uint256) {
        return nextPoolId - 1;
    }

    function isPoolActive(uint256 poolId) external view returns (bool) {
        return _isActive(poolId);
    }

    function isPoolEnded(uint256 poolId) external view returns (bool) {
        return _isEnded(poolId);
    }

    function isPoolCalculated(uint256 poolId) external view returns (bool) {
        return _isCalculated(poolId);
    }

    function getPoolLayers(
        uint256 poolId // it is uint256 because of EnumerableSet.UintSet. We don't convert to save gas
    ) external view returns (uint256[] memory) {
        return _poolLayers[poolId].values();
    }

    /** ------------------------------------------------
     *  ! Internal Helpers
     * ------------------------------------------------ */

    function _isStarted(uint256 poolId) internal view returns (bool) {
        return
            pools[poolId].startDay <= _getCurrentDay() &&
            pools[poolId].startDay != 0;
    }

    function _isEnded(uint256 poolId) internal view returns (bool) {
        return
            pools[poolId].endDay < _getCurrentDay() &&
            pools[poolId].endDay != 0;
    }

    function _isActive(uint256 poolId) internal view returns (bool) {
        return _isStarted(poolId) && !_isEnded(poolId);
    }

    function _isCalculated(uint256 poolId) internal view returns (bool) {
        return pools[poolId].totalPoolWeight > 0;
    }

    function _getCurrentDay() internal view virtual returns (uint16) {
        return uint16(block.timestamp / 1 days);
    }
}
