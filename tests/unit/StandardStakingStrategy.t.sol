// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../../src/reward-system/strategies/StandardStakingStrategy.sol";
import "../helpers/MockERC20.sol";
import "../../src/interfaces/staking/IStakingStorage.sol";
import "../../src/interfaces/reward/IRewardStrategy.sol";

// Lean Mock: Implements only necessary functions and reverts on unexpected calls.
contract MockStakingStorageForStrategy is IStakingStorage {
    mapping(bytes32 => Stake) public stakes;

    function getStake(
        bytes32 _stakeId
    ) external view override returns (Stake memory) {
        return stakes[_stakeId];
    }

    function mockStake(
        bytes32 _stakeId,
        address _owner,
        uint128 _amount,
        uint16 _stakeDay,
        uint16 _unstakeDay,
        uint16 _daysLock,
        uint16 _flags
    ) public {
        stakes[_stakeId] = Stake({
            amount: _amount,
            stakeDay: _stakeDay,
            unstakeDay: _unstakeDay,
            daysLock: _daysLock,
            flags: _flags
        });
    }

    // --- Unused functions revert to catch unexpected calls ---
    function createStake(
        address,
        uint128,
        uint16,
        uint16
    ) external override returns (bytes32) {
        revert("Not Implemented");
    }
    function removeStake(address, bytes32) external override {
        revert("Not Implemented");
    }
    function isActiveStake(bytes32) external view override returns (bool) {
        revert("Not Implemented");
    }
    function getStakerInfo(
        address
    ) external view override returns (StakerInfo memory) {
        revert("Not Implemented");
    }
    function getStakerBalance(
        address
    ) external view override returns (uint128) {
        revert("Not Implemented");
    }
    function getStakerBalanceAt(
        address,
        uint16
    ) external view override returns (uint128) {
        revert("Not Implemented");
    }
    function batchGetStakerBalances(
        address[] memory,
        uint16
    ) external view override returns (uint128[] memory) {
        revert("Not Implemented");
    }
    function getDailySnapshot(
        uint16
    ) external view override returns (DailySnapshot memory) {
        revert("Not Implemented");
    }
    function getCurrentTotalStaked() external view override returns (uint128) {
        revert("Not Implemented");
    }
    function getStakersPaginated(
        uint256,
        uint256
    ) external view override returns (address[] memory) {
        revert("Not Implemented");
    }
    function getTotalStakersCount() external view override returns (uint256) {
        revert("Not Implemented");
    }
    function getStakerStakeIds(
        address
    ) external view override returns (bytes32[] memory) {
        revert("Not Implemented");
    }
}

contract StandardStakingStrategyTest is Test {
    StandardStakingStrategy public strategy;
    MockERC20 public mockRewardToken;
    MockStakingStorageForStrategy public mockStakingStorage;

    address public user = address(0x123);
    bytes32 public stakeId;

    function setUp() public {
        mockRewardToken = new MockERC20("RewardToken", "RWT");
        mockStakingStorage = new MockStakingStorageForStrategy();
        strategy = new StandardStakingStrategy(address(mockRewardToken), false); // Re-staking not allowed by default
        stakeId = _generateStakeId(user, 0);
    }

    function _generateStakeId(address staker, uint32 counter) internal pure returns (bytes32) {
        return bytes32((uint256(uint160(staker)) << 96) | counter);
    }

    function test_GetParameters() public {
        (
            string memory name,
            address rewardToken,
            uint8 rewardLayer,
            IRewardStrategy.Policy stackingPolicy,
            IRewardStrategy.ClaimType claimType
        ) = strategy.getParameters();
        assertEq(name, "Standard Staking Strategy");
        assertEq(rewardToken, address(mockRewardToken));
        assertEq(rewardLayer, 0);
        assertEq(
            uint8(stackingPolicy),
            uint8(IRewardStrategy.Policy.STACKABLE)
        );
        assertEq(
            uint8(claimType),
            uint8(IRewardStrategy.ClaimType.ADMIN_GRANTED)
        );
    }

    function test_CalculateReward_FullPeriod() public {
        mockStakingStorage.mockStake(stakeId, user, 1000, 1, 0, 0, 0); // Stake from day 1, active
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 1000 * 30); // 1000 amount * 30 days
    }

    function test_CalculateReward_PartialPeriod_Start() public {
        mockStakingStorage.mockStake(stakeId, user, 1000, 10, 0, 0, 0); // Stake from day 10, active
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 1000 * (30 - 10 + 1)); // 1000 amount * 21 days
    }

    function test_CalculateReward_PartialPeriod_End() public {
        strategy = new StandardStakingStrategy(address(mockRewardToken), true);
        mockStakingStorage.mockStake(stakeId, user, 1000, 1, 20, 0, 0); // Stake from day 1, unstaked day 20
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 1000 * 20);
    }

    function test_CalculateReward_PartialPeriod_Middle() public {
        strategy = new StandardStakingStrategy(address(mockRewardToken), true);
        mockStakingStorage.mockStake(stakeId, user, 1000, 10, 20, 0, 0); // Stake from day 10, unstaked day 20
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 1000 * (20 - 10 + 1)); // 1000 amount * 11 days
    }

    function test_CalculateReward_NoOverlap() public {
        mockStakingStorage.mockStake(stakeId, user, 1000, 31, 40, 0, 0); // Stake outside pool
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 0);
    }

    function test_CalculateReward_UnstakedDuringPool_NoReStakingAllowed()
        public
    {
        mockStakingStorage.mockStake(stakeId, user, 1000, 1, 15, 0, 0); // Stake from day 1, unstaked day 15
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        // Strategy initialized with re-staking NOT allowed
        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 0); // Should be 0 due to withdrawal
    }

    function test_CalculateReward_UnstakedDuringPool_ReStakingAllowed() public {
        strategy = new StandardStakingStrategy(address(mockRewardToken), true); // Re-staking allowed
        mockStakingStorage.mockStake(stakeId, user, 1000, 1, 15, 0, 0); // Stake from day 1, unstaked day 15
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 1000 * 15);
    }

    function test_CalculateReward_StakeStartsAfterPoolEnds() public {
        mockStakingStorage.mockStake(stakeId, user, 1000, 31, 0, 0, 0); // Stake starts after pool ends
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 1, 30); // Pool from day 1 to 30
        assertEq(rewardWeight, 0);
    }

    function test_CalculateReward_StakeEndsBeforePoolStarts() public {
        mockStakingStorage.mockStake(stakeId, user, 1000, 1, 5, 0, 0); // Stake ends before pool starts
        IStakingStorage.Stake memory stake = mockStakingStorage.getStake(
            stakeId
        );

        uint256 rewardWeight = strategy.calculateReward(user, stake, 10, 20); // Pool from day 10 to 20
        assertEq(rewardWeight, 0);
    }
}
