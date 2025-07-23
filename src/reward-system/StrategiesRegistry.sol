// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/reward/RewardErrors.sol";

/**
 * @title StrategiesRegistry
 * @author @Tudmotu
 * @notice A simple registry for mapping a strategy ID to a contract address.
 */
contract StrategiesRegistry is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping(uint32 id => address contractAddress) private _strategies;

    event StrategyRegistered(
        uint32 indexed strategyId,
        address indexed strategyAddress
    );
    event StrategyRemoved(uint32 indexed strategyId);

    constructor(address _admin, address _manager) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MANAGER_ROLE, _manager);
    }

    /**
     * @notice Registers a new strategy or updates an existing one.
     * @param _strategyId The unique ID for the strategy (e.g., keccak256("STANDARD_V1")).
     * @param _strategyAddress The address of the deployed strategy contract.
     */
    function registerStrategy(
        uint32 _strategyId,
        address _strategyAddress
    ) external onlyRole(MANAGER_ROLE) {
        require(
            _strategyAddress != address(0),
            RewardErrors.StrategyExist(_strategyId)
        );
        _strategies[_strategyId] = _strategyAddress;
        emit StrategyRegistered(_strategyId, _strategyAddress);
    }

    /**
     * @notice Removes a strategy from the registry.
     * @param _strategyId The ID of the strategy to remove.
     */
    function removeStrategy(
        uint32 _strategyId
    ) external onlyRole(MANAGER_ROLE) {
        require(
            _strategies[_strategyId] != address(0),
            RewardErrors.StrategyNotRegistered(_strategyId)
        );
        _strategies[_strategyId] = address(0);
        emit StrategyRemoved(_strategyId);
    }

    /**
     * @notice Gets the address of a registered strategy.
     * @param _strategyId The ID of the strategy.
     * @return The contract address of the strategy.
     */
    function getStrategyAddress(
        uint32 _strategyId
    ) external view returns (address) {
        return _strategies[_strategyId];
    }

    /**
     * @notice Checks if a strategy is registered.
     * @param _strategyId The ID of the strategy to check.
     * @return True if the strategy is registered, false otherwise.
     */
    function isStrategyRegistered(
        uint32 _strategyId
    ) external view returns (bool) {
        return _strategies[_strategyId] != address(0);
    }
}
