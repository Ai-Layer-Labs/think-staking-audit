// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../../src/reward-system/RewardManager.sol";
import "../../src/reward-system/RewardBookkeeper.sol";
import "../../src/reward-system/StrategiesRegistry.sol";
import "../../src/interfaces/reward/IRewardStrategy.sol";
import "../../src/interfaces/staking/IStakingStorage.sol";
import "../../src/interfaces/staking/IStakingVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../helpers/MockERC20.sol";

// Mocks remain largely the same as they are for interfaces, not concrete implementations.
// Lean Mock: Implements only necessary functions and reverts on unexpected calls.
contract LeanMockStakingStorage is IStakingStorage {
    mapping(bytes32 stakeId => Stake stake) public stakes;
    mapping(address staker => bytes32[] stakeIds) public stakerStakeIds;

    function getStake(
        bytes32 _stakeId
    ) external view override returns (Stake memory) {
        return stakes[_stakeId];
    }

    function getStakerStakeIds(
        address _staker
    ) external view override returns (bytes32[] memory) {
        return stakerStakeIds[_staker];
    }

    function mockStake(
        bytes32 _stakeId,
        address _owner,
        uint128 _amount,
        uint16 _stakeDay
    ) public {
        stakes[_stakeId] = Stake({
            amount: _amount,
            stakeDay: _stakeDay,
            unstakeDay: 0,
            daysLock: 0,
            flags: 0
        });
        stakerStakeIds[_owner].push(_stakeId);
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
    function getTotalStakersCount() external view override returns (uint256) {
        revert("Not Implemented");
    }
    function getStakersPaginated(
        uint256,
        uint256
    ) external view override returns (address[] memory) {
        revert("Not Implemented");
    }
}

contract MockRewardStrategy is IRewardStrategy {
    string public mockName;
    address public mockRewardToken;
    uint8 public mockRewardLayer;
    Policy public mockStackingPolicy;
    ClaimType public mockClaimType;
    uint256 public mockCalculatedReward;

    constructor(
        string memory _name,
        address _rewardToken,
        uint8 _layer,
        Policy _policy,
        ClaimType _claimType
    ) {
        mockName = _name;
        mockRewardToken = _rewardToken;
        mockRewardLayer = _layer;
        mockStackingPolicy = _policy;
        mockClaimType = _claimType;
    }

    function getParameters()
        external
        view
        override
        returns (
            string memory name,
            address rewardToken,
            uint8 rewardLayer,
            Policy stackingPolicy,
            ClaimType claimType
        )
    {
        return (
            mockName,
            mockRewardToken,
            mockRewardLayer,
            mockStackingPolicy,
            mockClaimType
        );
    }

    function calculateReward(
        address,
        IStakingStorage.Stake memory stake,
        uint256 startTime,
        uint256 endTime
    ) external view override returns (uint256) {
        if (mockCalculatedReward > 0) return mockCalculatedReward;
        return stake.amount * (endTime - startTime); // Simplified logic
    }

    function setMockCalculatedReward(uint256 _amount) public {
        mockCalculatedReward = _amount;
    }
}

contract LeanMockStakingVault is IStakingVault {
    bytes32 public constant CLAIM_CONTRACT_ROLE =
        keccak256("CLAIM_CONTRACT_ROLE");
    mapping(address => bool) public isClaimContract;
    address public lastStaker;
    uint128 public lastAmount;
    uint16 public lastDaysLock;

    event StakeFromClaimCalled(
        address indexed staker,
        uint128 amount,
        uint16 daysLock
    );

    function grantRole(bytes32 role, address account) public {
        if (role == CLAIM_CONTRACT_ROLE) isClaimContract[account] = true;
    }

    function stakeFromClaim(
        address staker,
        uint128 amount,
        uint16 daysLock
    ) external override returns (bytes32) {
        require(
            isClaimContract[msg.sender],
            "MockStakingVault: Caller is not a claim contract"
        );
        lastStaker = staker;
        lastAmount = amount;
        lastDaysLock = daysLock;
        bytes32 stakeId = keccak256(abi.encodePacked(staker, amount, daysLock));
        emit StakeFromClaimCalled(staker, amount, daysLock);
        return stakeId;
    }

    function stake(uint128, uint16) external override returns (bytes32) {
        revert("Not Implemented");
    }
    function unstake(bytes32) external override {
        revert("Not Implemented");
    }
}

contract RewardManagerTest is Test {
    RewardManager public rewardManager;
    StrategiesRegistry public strategiesRegistry;
    RewardBookkeeper public rewardBookkeeper;
    LeanMockStakingStorage public mockStakingStorage;
    LeanMockStakingVault public mockStakingVault;
    MockERC20 public mockRewardToken;

    address public admin = address(0xA1);
    address public manager = address(0xB1);
    address public user1 = address(0xC1);

    uint32 constant STRATEGY_ID_GRANTED_COMPAT = 0;
    uint32 constant STRATEGY_ID_IMMEDIATE = 1;
    uint32 constant STRATEGY_ID_EXCLUSIVE = 2;

    function setUp() public {
        strategiesRegistry = new StrategiesRegistry(admin, manager);
        rewardBookkeeper = new RewardBookkeeper(admin, manager);
        mockStakingStorage = new LeanMockStakingStorage();
        mockStakingVault = new LeanMockStakingVault();
        mockRewardToken = new MockERC20("RewardToken", "RWT");

        rewardManager = new RewardManager(
            admin,
            manager,
            mockStakingStorage,
            strategiesRegistry,
            rewardBookkeeper,
            IStakingVault(address(mockStakingVault))
        );

        // Grant necessary roles
        vm.startPrank(admin);
        mockStakingVault.grantRole(
            mockStakingVault.CLAIM_CONTRACT_ROLE(),
            address(rewardManager)
        );
        rewardBookkeeper.grantRole(
            rewardBookkeeper.CONTROLLER_ROLE(),
            address(rewardManager)
        );
        rewardBookkeeper.grantRole(rewardBookkeeper.MANAGER_ROLE(), manager); // For test setup
        vm.stopPrank();

        // Mint and approve tokens for the RewardManager contract to spend
        mockRewardToken.mint(address(rewardManager), 1_000_000 * 10 ** 18);
    }

    function _registerStrategy(
        uint32 strategyId,
        IRewardStrategy.ClaimType claimType,
        uint8 layer,
        IRewardStrategy.Policy policy
    ) internal {
        if (strategiesRegistry.getStrategyAddress(strategyId) == address(0)) {
            MockRewardStrategy mockStrategy = new MockRewardStrategy(
                "Strategy",
                address(mockRewardToken),
                layer,
                policy,
                claimType
            );
            vm.startPrank(manager);
            strategiesRegistry.registerStrategy(
                strategyId,
                address(mockStrategy)
            );
            vm.stopPrank();
        }
    }

    function test_ClaimGrantedRewards_Success() public {
        _registerStrategy(
            STRATEGY_ID_GRANTED_COMPAT,
            IRewardStrategy.ClaimType.ADMIN_GRANTED,
            0,
            IRewardStrategy.Policy.STACKABLE
        );

        uint256 rewardAmount = 1000 * 10 ** 18;

        // Simulate admin granting a reward
        vm.startPrank(admin);
        rewardBookkeeper.grantRole(rewardBookkeeper.CONTROLLER_ROLE(), manager); // Admin grants role to manager
        vm.stopPrank();

        vm.startPrank(manager); // Now manager, with the correct role, can grant the reward
        rewardBookkeeper.grantReward(
            user1,
            STRATEGY_ID_GRANTED_COMPAT,
            1,
            rewardAmount,
            1
        ); // Use the registered strategy ID
        vm.stopPrank();

        // User claims the reward
        vm.startPrank(user1);
        uint256 userBalanceBefore = mockRewardToken.balanceOf(user1);
        rewardManager.claimGrantedRewards();
        uint256 userBalanceAfter = mockRewardToken.balanceOf(user1);
        vm.stopPrank();

        assertEq(userBalanceAfter - userBalanceBefore, rewardAmount);
    }

    function _generateStakeId(
        address staker,
        uint32 counter
    ) internal pure returns (bytes32) {
        return bytes32((uint256(uint160(staker)) << 96) | counter);
    }

    function test_ClaimImmediateReward_Success() public {
        _registerStrategy(
            STRATEGY_ID_IMMEDIATE,
            IRewardStrategy.ClaimType.USER_CLAIMABLE,
            0,
            IRewardStrategy.Policy.STACKABLE
        );

        // Fund the strategy
        uint256 depositAmount = 5000 * 10 ** 18;
        mockRewardToken.mint(manager, depositAmount);
        vm.startPrank(manager);
        mockRewardToken.approve(address(rewardManager), depositAmount);
        rewardManager.depositForStrategy(STRATEGY_ID_IMMEDIATE, depositAmount);
        vm.stopPrank();

        bytes32 stakeId = _generateStakeId(user1, 0);
        mockStakingStorage.mockStake(stakeId, user1, 100, 1);

        vm.warp(10 days);

        // Claim reward
        vm.startPrank(user1);
        uint256 balanceBefore = mockRewardToken.balanceOf(user1);
        uint256 claimedAmount = rewardManager.claimImmediateReward(
            STRATEGY_ID_IMMEDIATE,
            stakeId
        );
        uint256 balanceAfter = mockRewardToken.balanceOf(user1);
        vm.stopPrank();

        assertTrue(claimedAmount > 0);
        assertEq(balanceAfter - balanceBefore, claimedAmount);
        assertEq(
            rewardManager.lastClaimDay(stakeId, STRATEGY_ID_IMMEDIATE),
            10
        );
    }

    function test_ClaimImmediateAndRestake_Success() public {
        _registerStrategy(
            STRATEGY_ID_IMMEDIATE,
            IRewardStrategy.ClaimType.USER_CLAIMABLE,
            0,
            IRewardStrategy.Policy.STACKABLE
        );

        uint256 depositAmount = 5000 * 10 ** 18;
        mockRewardToken.mint(address(rewardManager), depositAmount); // Fund manager directly

        bytes32 stakeId = _generateStakeId(user1, 0);
        mockStakingStorage.mockStake(stakeId, user1, 100, 1);

        vm.warp(10 days);

        MockRewardStrategy mockStrategy = MockRewardStrategy(
            strategiesRegistry.getStrategyAddress(STRATEGY_ID_IMMEDIATE)
        );
        uint256 expectedReward = 1000 * 10 ** 18;
        mockStrategy.setMockCalculatedReward(expectedReward);

        vm.startPrank(user1);
        vm.expectEmit(true, true, true, true);
        emit LeanMockStakingVault.StakeFromClaimCalled(
            user1,
            uint128(expectedReward),
            30
        );
        rewardManager.claimImmediateAndRestake(
            STRATEGY_ID_IMMEDIATE,
            stakeId,
            30
        );
        vm.stopPrank();

        assertEq(mockStakingVault.lastStaker(), user1);
        assertEq(mockStakingVault.lastAmount(), expectedReward);
        assertEq(mockStakingVault.lastDaysLock(), 30);
    }
}
