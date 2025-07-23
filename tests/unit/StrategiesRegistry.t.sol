// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {StrategiesRegistry} from "../../src/reward-system/StrategiesRegistry.sol";
import {RewardErrors} from "../../src/interfaces/reward/RewardErrors.sol";

error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

contract StrategiesRegistryTest is Test {
    StrategiesRegistry public registry;

    address public admin = address(0xA1);
    address public manager = address(0xB1);
    address public strategyAddress = address(0xD1);
    uint16 constant STRATEGY_ID = 1;

    function setUp() public {
        registry = new StrategiesRegistry(admin, manager);
    }

    function test_RegisterAndGetStrategy() public {
        vm.startPrank(manager);
        registry.registerStrategy(STRATEGY_ID, strategyAddress);
        vm.stopPrank();

        assertTrue(registry.isStrategyRegistered(STRATEGY_ID));
        assertEq(registry.getStrategyAddress(STRATEGY_ID), strategyAddress);
    }

    function test_TC_SR01_RemoveStrategy_Success() public {
        vm.startPrank(manager);
        registry.registerStrategy(STRATEGY_ID, strategyAddress);

        assertTrue(registry.isStrategyRegistered(STRATEGY_ID));

        registry.removeStrategy(STRATEGY_ID);
        vm.stopPrank();

        assertFalse(registry.isStrategyRegistered(STRATEGY_ID));
        assertEq(registry.getStrategyAddress(STRATEGY_ID), address(0));
    }

    function test_RemoveStrategy_Fail_NotRegistered() public {
        vm.startPrank(manager);
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardErrors.StrategyNotRegistered.selector,
                STRATEGY_ID
            )
        );
        registry.removeStrategy(STRATEGY_ID);
        vm.stopPrank();
    }

    function test_RegisterStrategy_Fail_NotManager() public {
        vm.startPrank(admin); // Not manager
        bytes32 managerRole = registry.MANAGER_ROLE();
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                admin,
                managerRole
            )
        );
        registry.registerStrategy(STRATEGY_ID, strategyAddress);
        vm.stopPrank();
    }
}
