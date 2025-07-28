// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../../src/reward-system/PoolManager.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

contract PoolManagerTest is Test {
    PoolManager poolManager;
    address admin = makeAddr("admin");
    address manager = makeAddr("manager");
    address controller = makeAddr("controller");
    address user = makeAddr("user");

    uint256 constant POOL_ID = 1;

    function setUp() public {
        vm.prank(admin);
        poolManager = new PoolManager(admin, manager, controller);
    }

    function test_UpsertPool_Success() public {
        vm.prank(manager);
        uint256 poolId = poolManager.upsertPool(0, 10, 100, 999);
        assertEq(poolId, 1, "Pool ID should be 1");

        PoolManager.Pool memory pool = poolManager.getPool(poolId);
        assertEq(pool.startDay, 10, "Start day mismatch");
        assertEq(pool.endDay, 100, "End day mismatch");
    }

    function test_UpsertPool_Fail_IfPoolAlreadyStarted() public {
        // Setup: create a pool that starts on day 10
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        // Warp time to day 11, after the pool has started
        vm.warp(11 days);

        // Attempt to update the started pool
        vm.prank(manager);
        vm.expectRevert(PoolManager.PoolAlreadyStarted.selector);
        poolManager.upsertPool(POOL_ID, 11, 101, 0);
    }

    function test_AssignStrategy_Fail_IfPoolAlreadyStarted() public {
        // Setup: create a pool that starts on day 10
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        // Warp time to day 11
        vm.warp(11 days);

        // Attempt to assign a strategy to the started pool
        vm.prank(manager);
        vm.expectRevert(PoolManager.PoolAlreadyStarted.selector);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );
    }

    function test_SetTotalStakeWeight_Success() public {
        // Setup: create a pool that ends on day 100
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        PoolManager.Pool memory poolAfterUpsert = poolManager.getPool(POOL_ID);
        assertEq(
            poolAfterUpsert.endDay,
            100,
            "End day not set correctly after upsert"
        );

        // Warp time to day 101, after the pool has ended
        vm.warp(101 days);

        uint128 totalWeight = 1_000_000 * 1e18;
        vm.prank(controller);
        poolManager.setPoolTotalStakeWeight(POOL_ID, totalWeight);

        PoolManager.Pool memory pool = poolManager.getPool(POOL_ID);
        assertEq(
            pool.totalPoolWeight,
            totalWeight,
            "Total stake weight mismatch"
        );
    }

    function test_SetTotalStakeWeight_Fail_IfNotEnded() public {
        // Setup: create a pool that ends on day 100
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        // Warp time to day 50, while the pool is still active
        vm.warp(50 days);

        vm.prank(controller);
        vm.expectRevert(PoolManager.PoolNotEnded.selector);
        poolManager.setPoolTotalStakeWeight(POOL_ID, 1_000_000 * 1e18);
    }

    function test_SetTotalStakeWeight_Fail_IfNotController() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.warp(101 days);

        vm.prank(user); // Not a controller
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                address(this),
                poolManager.CONTROLLER_ROLE()
            )
        );
        poolManager.setPoolTotalStakeWeight(POOL_ID, 1_000_000 * 1e18);
    }

    function test_SetPoolLiveWeight_Success() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        uint256 liveWeight = 500 * 1e18;
        vm.prank(controller);
        poolManager.setPoolLiveWeight(POOL_ID, liveWeight);

        assertEq(
            poolManager.poolLiveWeight(POOL_ID),
            liveWeight,
            "Live weight mismatch"
        );
    }

    function test_SetPoolLiveWeight_Fail_IfNotController() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        vm.prank(user); // Not a controller
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                address(this),
                poolManager.CONTROLLER_ROLE()
            )
        );
        poolManager.setPoolLiveWeight(POOL_ID, 500 * 1e18);
    }

    function test_RemoveLayer_Success() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );

        vm.prank(manager);
        poolManager.removeLayer(POOL_ID, 0);

        assertFalse(
            poolManager.hasLayer(POOL_ID, 0),
            "Layer should be removed"
        );
    }

    function test_RemoveLayer_Fail_IfPoolActive() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.warp(11 days);

        vm.prank(manager);
        vm.expectRevert(PoolManager.PoolAlreadyStarted.selector);
        poolManager.removeLayer(POOL_ID, 0);
    }

    function test_RemoveLayer_Fail_IfNotManager() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                address(this),
                poolManager.MANAGER_ROLE()
            )
        );
        poolManager.removeLayer(POOL_ID, 0);
    }

    function test_RemoveStrategyFromPool_Success() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );

        vm.prank(manager);
        poolManager.removeStrategyFromPool(POOL_ID, 0, 1);

        assertEq(
            poolManager.getLayerStrategies(POOL_ID, 0).length,
            0,
            "Strategy should be removed"
        );
    }

    function test_RemoveStrategyFromPool_Fail_IfPoolActive() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );
        vm.warp(11 days);

        vm.prank(manager);
        vm.expectRevert(PoolManager.PoolAlreadyStarted.selector);
        poolManager.removeStrategyFromPool(POOL_ID, 0, 1);
    }

    function test_RemoveStrategyFromPool_Fail_IfNotManager() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                address(this),
                poolManager.MANAGER_ROLE()
            )
        );
        poolManager.removeStrategyFromPool(POOL_ID, 0, 1);
    }

    function test_GetStrategyLayer() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );

        assertEq(poolManager.getStrategyLayer(POOL_ID, 1), 0, "Layer mismatch");
    }

    function test_GetStrategyExclusivity() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );

        assertEq(
            uint8(poolManager.getStrategyExclusivity(1)),
            uint8(PoolManager.StrategyExclusivity.NORMAL),
            "Exclusivity mismatch"
        );
    }

    function test_GetLayerStrategies() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            2,
            PoolManager.StrategyExclusivity.EXCLUSIVE
        );

        uint32[] memory strategies = poolManager.getLayerStrategies(POOL_ID, 0);
        assertEq(strategies.length, 2, "Strategy count mismatch");
        assertEq(strategies[0], 1, "Strategy ID mismatch");
        assertEq(strategies[1], 2, "Strategy ID mismatch");
    }

    function test_HasLayer() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );

        assertTrue(poolManager.hasLayer(POOL_ID, 0), "Layer should exist");
        assertFalse(poolManager.hasLayer(POOL_ID, 1), "Layer should not exist");
    }

    function test_GetPoolsByDateRange() public {
        vm.prank(manager);
        poolManager.upsertPool(0, 10, 20, 0);
        vm.prank(manager);
        poolManager.upsertPool(0, 15, 25, 0);
        vm.prank(manager);
        poolManager.upsertPool(0, 30, 40, 0);

        uint256[] memory poolsInRange = poolManager.getPoolsByDateRange(12, 22);
        assertEq(poolsInRange.length, 2, "Pool count mismatch");
        assertEq(poolsInRange[0], 1, "Pool ID mismatch");
        assertEq(poolsInRange[1], 2, "Pool ID mismatch");
    }

    function test_GetPools() public {
        vm.prank(manager);
        poolManager.upsertPool(0, 10, 20, 0);
        vm.prank(manager);
        poolManager.upsertPool(0, 15, 25, 0);

        uint256[] memory poolIds = new uint256[](2);
        poolIds[0] = 1;
        poolIds[1] = 2;

        PoolManager.Pool[] memory pools = poolManager.getPools(poolIds);
        assertEq(pools.length, 2, "Pool count mismatch");
        assertEq(pools[0].startDay, 10, "Pool 1 start day mismatch");
        assertEq(pools[1].startDay, 15, "Pool 2 start day mismatch");
    }

    function test_GetPoolCount() public {
        vm.prank(manager);
        poolManager.upsertPool(0, 10, 20, 0);
        vm.prank(manager);
        poolManager.upsertPool(0, 15, 25, 0);

        assertEq(poolManager.getPoolCount(), 2, "Pool count mismatch");
    }

    function test_IsPoolActive() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        vm.warp(11 days);
        assertTrue(poolManager.isPoolActive(POOL_ID), "Pool should be active");

        vm.warp(101 days);
        assertFalse(
            poolManager.isPoolActive(POOL_ID),
            "Pool should not be active"
        );
    }

    function test_IsPoolEnded() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        vm.warp(101 days);
        assertTrue(poolManager.isPoolEnded(POOL_ID), "Pool should be ended");

        vm.warp(50 days);
        assertFalse(
            poolManager.isPoolEnded(POOL_ID),
            "Pool should not be ended"
        );
    }

    function test_IsPoolCalculated() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);

        assertFalse(
            poolManager.isPoolCalculated(POOL_ID),
            "Pool should not be calculated initially"
        );

        vm.warp(101 days);
        vm.prank(controller);
        poolManager.setPoolTotalStakeWeight(POOL_ID, 1000);

        assertTrue(
            poolManager.isPoolCalculated(POOL_ID),
            "Pool should be calculated"
        );
    }

    function test_GetPoolLayers() public {
        vm.prank(manager);
        poolManager.upsertPool(POOL_ID, 10, 100, 0);
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            1,
            PoolManager.StrategyExclusivity.NORMAL
        );
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            1,
            2,
            PoolManager.StrategyExclusivity.EXCLUSIVE
        );

        uint256[] memory layers = poolManager.getPoolLayers(POOL_ID);
        assertEq(layers.length, 2, "Layer count mismatch");
        assertEq(layers[0], 0, "Layer ID mismatch");
        assertEq(layers[1], 1, "Layer ID mismatch");
    }
}
