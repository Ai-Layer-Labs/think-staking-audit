// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {SimpleUserClaimableStrategy} from "../../src/reward-system/strategies/SimpleUserClaimableStrategy.sol";
import {MockERC20} from "../helpers/MockERC20.sol";
import {IStakingStorage} from "../../src/interfaces/staking/IStakingStorage.sol";

contract SimpleUserClaimableStrategyTest is Test {
    SimpleUserClaimableStrategy public strategy;
    MockERC20 public mockRewardToken;
    IStakingStorage.Stake public mockStake;

    address public user = address(0x123);
    uint128 public constant STAKE_AMOUNT = 100 * 10**18;
    uint256 public constant REWARD_RATE_PER_DAY = 5;

    function setUp() public {
        mockRewardToken = new MockERC20("RewardToken", "RWT");
        strategy = new SimpleUserClaimableStrategy(address(mockRewardToken), REWARD_RATE_PER_DAY);
        
        mockStake = IStakingStorage.Stake({
            amount: STAKE_AMOUNT,
            stakeDay: 10,
            unstakeDay: 0,
            daysLock: 0,
            flags: 0
        });
    }

    function test_TC_SCS01_CalculateReward_FullPeriod() public {
        // Scenario: Stake is active for the full 10-day period (day 10 to 19)
        uint256 startDay = 10;
        uint256 endDay = 19;
        uint256 expectedReward = STAKE_AMOUNT * REWARD_RATE_PER_DAY * (endDay - startDay + 1); // 100 * 5 * 10

        uint256 reward = strategy.calculateReward(user, mockStake, startDay, endDay);
        assertEq(reward, expectedReward);
    }

    function test_TC_SCS02_CalculateReward_PartialPeriod_StakeStartsLate() public {
        // Scenario: Claim period is day 1 to 15, but stake only started on day 10.
        uint256 startDay = 1;
        uint256 endDay = 15;
        // Effective period is day 10 to 15 (6 days)
        uint256 expectedReward = STAKE_AMOUNT * REWARD_RATE_PER_DAY * (endDay - mockStake.stakeDay + 1);

        uint256 reward = strategy.calculateReward(user, mockStake, startDay, endDay);
        assertEq(reward, expectedReward);
    }

    function test_TC_SCS02_CalculateReward_PartialPeriod_StakeEndsEarly() public {
        // Scenario: Claim period is day 10 to 25, but stake was unstaked on day 20.
        mockStake.unstakeDay = 20;
        uint256 startDay = 10;
        uint256 endDay = 25;
        // Effective period is day 10 to 20 (11 days)
        uint256 expectedReward = STAKE_AMOUNT * REWARD_RATE_PER_DAY * (mockStake.unstakeDay - startDay + 1);

        uint256 reward = strategy.calculateReward(user, mockStake, startDay, endDay);
        assertEq(reward, expectedReward);
    }

    function test_CalculateReward_NoOverlap() public {
        // Scenario: Claim period is day 1 to 5, but stake starts on day 10.
        uint256 reward = strategy.calculateReward(user, mockStake, 1, 5);
        assertEq(reward, 0);
    }
}
