// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {RewardBookkeeper} from "../../src/reward-system/RewardBookkeeper.sol";

contract RewardBookkeeperTest is Test {
    RewardBookkeeper public bookkeeper;

    address public admin = address(0xA1);
    address public manager = address(0xB1);
    address public controller = address(0xD1);
    address public user1 = address(0xC1);
    address public user2 = address(0xC2);

    function setUp() public {
        bookkeeper = new RewardBookkeeper(admin, manager);
        vm.startPrank(manager);
        bookkeeper.initController(controller);
        vm.stopPrank();
    }

    function test_TC_RBK01_GetUserRewards_Success() public {
        vm.startPrank(controller);
        bookkeeper.grantReward(user1, 1, 1, 100, 1);
        bookkeeper.grantReward(user1, 2, 1, 200, 2);
        bookkeeper.markRewardClaimed(user1, 0);
        vm.stopPrank();

        RewardBookkeeper.GrantedReward[] memory rewards = bookkeeper.getUserRewards(user1);
        assertEq(rewards.length, 2);
        assertEq(rewards[0].amount, 100);
        assertTrue(rewards[0].claimed);
        assertEq(rewards[1].amount, 200);
        assertFalse(rewards[1].claimed);
    }

    function test_TC_RBK01_GetUserClaimableAmount_Success() public {
        vm.startPrank(controller);
        bookkeeper.grantReward(user1, 1, 1, 100, 1);
        bookkeeper.grantReward(user1, 2, 1, 200, 2);
        bookkeeper.grantReward(user1, 3, 1, 300, 1);
        bookkeeper.markRewardClaimed(user1, 0);
        vm.stopPrank();

        uint256 claimableAmount = bookkeeper.getUserClaimableAmount(user1);
        assertEq(claimableAmount, 500); // 200 + 300
    }

    function test_TC_RBK01_GetUserClaimableRewards_Success() public {
        vm.startPrank(controller);
        bookkeeper.grantReward(user1, 1, 1, 100, 1);
        bookkeeper.grantReward(user1, 2, 1, 200, 2);
        bookkeeper.grantReward(user1, 3, 1, 300, 1);
        bookkeeper.markRewardClaimed(user1, 0);
        vm.stopPrank();

        (RewardBookkeeper.GrantedReward[] memory rewards, uint256[] memory indices) = bookkeeper.getUserClaimableRewards(user1);
        assertEq(rewards.length, 2);
        assertEq(indices.length, 2);
        assertEq(rewards[0].amount, 200);
        assertEq(indices[0], 1);
        assertEq(rewards[1].amount, 300);
        assertEq(indices[1], 2);
    }

    function test_TC_RBK01_GetUserRewardsPaginated_Success() public {
        vm.startPrank(controller);
        for (uint16 i = 0; i < 5; i++) {
            bookkeeper.grantReward(user1, i + 1, 1, (i + 1) * 100, 1);
        }
        vm.stopPrank();

        RewardBookkeeper.GrantedReward[] memory rewards = bookkeeper.getUserRewardsPaginated(user1, 2, 2);
        assertEq(rewards.length, 2);
        assertEq(rewards[0].amount, 300);
        assertEq(rewards[1].amount, 400);
    }
}
