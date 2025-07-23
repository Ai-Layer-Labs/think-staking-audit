// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../../src/reward-system/PoolManager.sol";
import "../../src/interfaces/reward/IEnums.sol";

contract PoolManagerTest is IEnums, Test {
    PoolManager public poolManager;

    address public admin = address(0xA1);
    address public manager = address(0xB1);
    uint32 constant DUMMY_STRATEGY_ID = type(uint32).max - 1;

    function setUp() public {
        poolManager = new PoolManager(admin, manager);
    }

    // ============================================================================
    //                           upsertPool Tests
    // ============================================================================

    function test_UpsertPool_NewPool_Success() public {
        vm.startPrank(manager);
        vm.expectEmit(true, true, true, true);
        emit PoolManager.PoolUpserted(1, 1, 10, 0, DUMMY_STRATEGY_ID);
        vm.expectEmit(true, false, false, false);
        emit PoolManager.PoolStateChanged(1, PoolState.ANNOUNCED);

        uint32 poolId = poolManager.upsertPool(0, 1, 10, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();

        assertEq(poolId, 1);
        (
            uint32 id,
            uint16 startDay,
            uint16 endDay,
            uint32 strategyId,
            uint32 parentId
        ) = poolManager.pools(1);
        assertEq(id, 1);
        assertEq(startDay, 1);
        assertEq(endDay, 10);
        assertEq(parentId, 0, "parentId should be 0");
        assertEq(strategyId, DUMMY_STRATEGY_ID);
        assertEq(uint(poolManager.poolState(1)), uint(PoolState.ANNOUNCED));
        assertEq(poolManager.nextPoolId(), 2);
    }

    function test_UpsertPool_UpdateExisting_Success() public {
        vm.startPrank(manager);
        poolManager.upsertPool(0, 1, 10, 0, DUMMY_STRATEGY_ID);

        uint16 newStrategyId = 2;
        uint32 updatedPoolId = poolManager.upsertPool(
            1,
            2,
            12,
            0,
            newStrategyId
        );
        vm.stopPrank();

        assertEq(updatedPoolId, 1);
        (, uint16 startDay, uint16 endDay, uint32 strategyId, ) = poolManager
            .pools(1);
        assertEq(startDay, 2);
        assertEq(endDay, 12);
        assertEq(strategyId, newStrategyId);
        assertEq(poolManager.nextPoolId(), 2); // Should not increment
    }

    function test_UpsertPool_Fail_StrategyIdZero() public {
        vm.startPrank(manager);
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardErrors.StrategyNotRegistered.selector,
                0
            )
        );
        poolManager.upsertPool(0, 1, 10, 0, 0);
        vm.stopPrank();
    }

    function test_UpsertPool_Fail_PoolIsActive() public {
        vm.startPrank(manager);
        uint32 poolId = poolManager.upsertPool(0, 1, 10, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();

        vm.warp(5 days); // Move time to make the pool active
        poolManager.updatePoolState(poolId);
        assertEq(uint(poolManager.poolState(poolId)), uint(PoolState.ACTIVE));

        vm.startPrank(manager);
        vm.expectRevert(
            abi.encodeWithSelector(
                RewardErrors.PoolAlreadyActiveOrFinalized.selector,
                poolId
            )
        );
        poolManager.upsertPool(poolId, 2, 12, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();
    }

    // ============================================================================
    //                           updatePoolState Tests
    // ============================================================================

    function test_UpdatePoolState_AnnouncedToActive() public {
        vm.startPrank(manager);
        uint32 poolId = poolManager.upsertPool(0, 5, 15, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();

        vm.warp(6 days); // Move time to be within the pool's active period

        vm.expectEmit(true, false, false, false);
        emit PoolManager.PoolStateChanged(poolId, PoolState.ACTIVE);
        poolManager.updatePoolState(poolId);

        assertEq(uint(poolManager.poolState(poolId)), uint(PoolState.ACTIVE));
    }

    function test_UpdatePoolState_ActiveToEnded() public {
        vm.startPrank(manager);
        uint32 poolId = poolManager.upsertPool(0, 5, 15, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();

        vm.warp(6 days);
        poolManager.updatePoolState(poolId); // Move to ACTIVE

        vm.warp(16 days); // Move time to be after the pool's end day

        vm.expectEmit(true, false, false, false);
        emit PoolManager.PoolStateChanged(poolId, PoolState.ENDED);
        poolManager.updatePoolState(poolId);

        assertEq(uint(poolManager.poolState(poolId)), uint(PoolState.ENDED));
    }

    function test_UpdatePoolState_Fail_AlreadyCalculated() public {
        vm.startPrank(manager);
        uint32 poolId = poolManager.upsertPool(0, 1, 2, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();

        vm.warp(3 days);
        poolManager.updatePoolState(poolId); // ANNOUNCED -> ACTIVE
        poolManager.updatePoolState(poolId); // ACTIVE -> ENDED

        vm.startPrank(manager);
        poolManager.finalizePool(poolId, 1000);
        vm.stopPrank();

        vm.expectRevert(
            abi.encodeWithSelector(
                RewardErrors.PoolNotInitializedOrCalculated.selector,
                poolId
            )
        );
        poolManager.updatePoolState(poolId);
    }

    // ============================================================================
    //                           finalizePool Tests
    // ============================================================================

    function test_FinalizePool_Success() public {
        vm.startPrank(manager);
        uint32 poolId = poolManager.upsertPool(0, 1, 5, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();

        vm.warp(10 days);
        poolManager.updatePoolState(poolId); // ANNOUNCED -> ACTIVE
        poolManager.updatePoolState(poolId); // ACTIVE -> ENDED
        assertEq(uint(poolManager.poolState(poolId)), uint(PoolState.ENDED));

        uint256 totalWeight = 50000 * 10 ** 18;
        vm.startPrank(manager);
        vm.expectEmit(true, false, false, false);
        emit PoolManager.PoolFinalized(poolId, totalWeight);
        vm.expectEmit(true, false, false, false);
        emit PoolManager.PoolStateChanged(poolId, PoolState.CALCULATED);
        poolManager.finalizePool(poolId, totalWeight);
        vm.stopPrank();

        assertEq(poolManager.poolTotalStakeWeight(poolId), totalWeight);
        assertEq(
            uint(poolManager.poolState(poolId)),
            uint(PoolState.CALCULATED)
        );
    }

    function test_FinalizePool_Fail_NotEnded() public {
        vm.startPrank(manager);
        uint32 poolId = poolManager.upsertPool(0, 1, 5, 0, DUMMY_STRATEGY_ID);
        vm.stopPrank();

        assertEq(
            uint(poolManager.poolState(poolId)),
            uint(PoolState.ANNOUNCED)
        );

        vm.startPrank(manager);
        vm.expectRevert(
            abi.encodeWithSelector(RewardErrors.PoolNotEnded.selector, poolId)
        );
        poolManager.finalizePool(poolId, 1000);
        vm.stopPrank();
    }
}
