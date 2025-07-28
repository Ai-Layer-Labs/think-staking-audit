// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../../src/reward-system/RewardManager.sol";
import "../../src/reward-system/PoolManager.sol";
import "../../src/reward-system/ClaimsJournal.sol";
import "../../src/reward-system/StrategiesRegistry.sol";
import "../../src/reward-system/strategies/FullStakingStrategy.sol";
import "../../src/interfaces/reward/IRewardStrategy.sol";
import "../../src/interfaces/staking/IStakingStorage.sol";
import "../helpers/MockERC20.sol";
import "../mocks/MockStakingStorage.sol";

/// @dev Internal mock for a POOL_SIZE_INDEPENDENT strategy (e.g., APR-based)
contract MockSimpleStrategy is IRewardStrategy, AccessControl {
    uint256 public constant APR = 10_000; // 10% with 2 decimals
    address public immutable rewardToken;

    constructor(address admin, address _rewardToken) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        rewardToken = _rewardToken;
    }

    function getStrategyType() external pure returns (StrategyType) {
        return IRewardStrategy.StrategyType.POOL_SIZE_INDEPENDENT;
    }

    function getName() external pure returns (string memory) {
        return "MockSimpleStrategy";
    }

    function getRewardToken() external view returns (address) {
        return rewardToken;
    }

    function getRewardLayer() external pure returns (uint8) {
        return 0; // Not used in this mock
    }

    function calculateReward(
        address, // user
        IStakingStorage.Stake calldata stake,
        uint16 poolStartDay,
        uint16 poolEndDay,
        uint16 lastClaimDay
    ) external view returns (uint256) {
        uint256 currentDay = block.timestamp / 1 days;
        uint256 startDay = lastClaimDay == 0 ? stake.stakeDay : lastClaimDay;

        if (currentDay <= startDay) {
            return 0;
        }

        uint256 daysToCalculate = currentDay - startDay;
        return (stake.amount * APR * daysToCalculate) / (100_000 * 365);
    }

    function calculateReward(
        address,
        IStakingStorage.Stake calldata,
        uint256,
        uint256,
        uint16,
        uint16
    ) external pure returns (uint256) {
        revert("MethodNotSupported");
    }
}

contract RewardManagerTest is Test {
    // --- Contracts ---
    RewardManager public rewardManager;
    PoolManager public poolManager;
    ClaimsJournal public claimsJournal;
    StrategiesRegistry public strategiesRegistry;
    MockStakingStorage public mockStakingStorage;
    MockERC20 public rewardToken;
    FullStakingStrategy public fullStakingStrategy;
    MockSimpleStrategy public simpleStrategy;

    // --- Users ---
    address public admin = makeAddr("ADMIN");
    address public manager = makeAddr("MANAGER");
    address public controller = makeAddr("CONTROLLER");
    address public user = makeAddr("USER");

    // --- IDs ---
    uint32 public constant POOL_ID = 1;
    uint32 public constant DEPENDENT_STRATEGY_ID = 1;
    uint32 public constant INDEPENDENT_STRATEGY_ID = 2;
    bytes32 public stakeId;

    function setUp() public {
        vm.prank(admin);
        poolManager = new PoolManager(admin, manager, controller);

        vm.prank(admin);
        strategiesRegistry = new StrategiesRegistry(admin, manager);

        vm.prank(admin);
        mockStakingStorage = new MockStakingStorage(admin);

        rewardToken = new MockERC20("Reward Token", "RWD");

        vm.prank(admin);
        fullStakingStrategy = new FullStakingStrategy(address(rewardToken), 14);

        simpleStrategy = new MockSimpleStrategy(admin, address(rewardToken));
        assertNotEq(address(simpleStrategy), address(0));
        assertEq(simpleStrategy.getRewardToken(), address(rewardToken));

        // Deploy RewardManager initially with a placeholder for ClaimsJournal
        vm.prank(admin);
        rewardManager = new RewardManager(
            admin,
            manager,
            mockStakingStorage,
            strategiesRegistry,
            ClaimsJournal(address(0)), // Placeholder
            poolManager
        );

        assertEq(
            rewardManager.hasRole(keccak256("MANAGER_ROLE"), manager),
            true,
            "Manager role not granted to manager"
        );

        // Now deploy ClaimsJournal with the real RewardManager address
        vm.prank(admin);
        claimsJournal = new ClaimsJournal(admin, address(rewardManager));

        // Finally, set the real ClaimsJournal in RewardManager
        vm.prank(admin);
        rewardManager.setClaimsJournal(claimsJournal);

        // Grant CONTROLLER_ROLE to the test contract for mocking stakes
        vm.prank(admin);
        mockStakingStorage.grantRole(
            keccak256("CONTROLLER_ROLE"),
            address(this)
        );

        // Grant REWARD_MANAGER_ROLE to the RewardManager contract in ClaimsJournal
        vm.prank(admin);
        claimsJournal.grantRole(
            keccak256("MANAGER_ROLE"),
            address(rewardManager)
        );

        // --- Initial State Setup ---
        vm.startPrank(manager);
        // Register strategies
        strategiesRegistry.registerStrategy(
            DEPENDENT_STRATEGY_ID,
            address(fullStakingStrategy)
        );
        strategiesRegistry.registerStrategy(
            INDEPENDENT_STRATEGY_ID,
            address(simpleStrategy)
        );

        assertEq(
            strategiesRegistry.getStrategyAddress(DEPENDENT_STRATEGY_ID),
            address(fullStakingStrategy)
        );
        assertEq(
            strategiesRegistry.getStrategyAddress(INDEPENDENT_STRATEGY_ID),
            address(simpleStrategy)
        );

        // Create a pool (e.g., from day 10 to day 100)
        vm.warp(10 days); // Set current time to day 10
        poolManager.upsertPool(POOL_ID, 11, 100, 0);

        // Assign strategies to pool layers
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            DEPENDENT_STRATEGY_ID,
            PoolManager.StrategyExclusivity.NORMAL
        );
        poolManager.assignStrategyToPool(
            POOL_ID,
            1,
            INDEPENDENT_STRATEGY_ID,
            PoolManager.StrategyExclusivity.NORMAL
        );

        // Fund the strategies
        rewardToken.mint(manager, 2_000_000 ether);
        rewardToken.approve(address(rewardManager), 2_000_000 ether);
        vm.stopPrank();

        vm.startPrank(manager);
        rewardManager.fundStrategy(DEPENDENT_STRATEGY_ID, 1_000_000 ether);

        rewardManager.fundStrategy(INDEPENDENT_STRATEGY_ID, 1_000_000 ether);

        // Create a stake for the user, starting on day 10
        vm.stopPrank();
        vm.prank(address(this));
        stakeId = mockStakingStorage.createStake(user, 1000 ether, 10, 0);
    }

    function test_ClaimReward_Success_DependentStrategy() public {
        // --- Setup ---
        vm.warp(101 days);
        vm.prank(controller);
        poolManager.setPoolTotalStakeWeight(POOL_ID, 2000 * 1e18);

        // --- Action ---
        vm.prank(user);
        rewardManager.claimReward(stakeId, POOL_ID, DEPENDENT_STRATEGY_ID);

        // --- Assertions ---
        assertEq(rewardToken.balanceOf(user), (1_000_000 * 1e18) / 2);
        assertEq(
            claimsJournal.getLastClaimDay(stakeId, DEPENDENT_STRATEGY_ID),
            101
        );
    }

    function test_ClaimReward_Fail_IfAlreadyClaimed_DependentStrategy() public {
        // --- Setup ---
        vm.warp(101 days);
        vm.prank(controller);
        poolManager.setPoolTotalStakeWeight(POOL_ID, 1000 * 1e18);

        // First claim
        vm.prank(user);
        rewardManager.claimReward(stakeId, POOL_ID, DEPENDENT_STRATEGY_ID);
        assertEq(rewardToken.balanceOf(user), 1_000_000 * 1e18);

        // --- Action ---
        vm.expectRevert("Reward already claimed");
        vm.prank(user);
        rewardManager.claimReward(stakeId, POOL_ID, DEPENDENT_STRATEGY_ID);
    }

    function test_ClaimReward_Success_IndependentStrategy() public {
        // --- Setup ---
        vm.warp(20 days); // 10 days after stake started

        // --- Action ---
        vm.prank(user);
        rewardManager.claimReward(stakeId, POOL_ID, INDEPENDENT_STRATEGY_ID);

        // --- Assertions ---
        uint256 expectedReward = uint256(1000 ether * 10_000 * 10) /
            (100_000 * 365);
        assertApproxEqAbs(rewardToken.balanceOf(user), expectedReward, 1e15);
        assertEq(
            claimsJournal.getLastClaimDay(stakeId, INDEPENDENT_STRATEGY_ID),
            20
        );
    }

    function test_ClaimReward_Fail_IfExclusiveClaimedOnLayer() public {
        // --- Setup ---
        vm.prank(manager);
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            DEPENDENT_STRATEGY_ID,
            PoolManager.StrategyExclusivity.EXCLUSIVE
        );

        vm.prank(manager);
        // Assign another strategy to the same layer to test exclusivity
        poolManager.assignStrategyToPool(
            POOL_ID,
            0,
            INDEPENDENT_STRATEGY_ID,
            PoolManager.StrategyExclusivity.NORMAL
        );

        // User claims the exclusive reward
        vm.warp(101 days);
        vm.prank(controller);
        poolManager.setPoolTotalStakeWeight(POOL_ID, 1000 * 1e18);
        vm.prank(user);
        rewardManager.claimReward(stakeId, POOL_ID, DEPENDENT_STRATEGY_ID);

        // --- Action ---
        vm.expectRevert(bytes("Layer locked by exclusive claim"));
        vm.prank(user);
        rewardManager.claimReward(stakeId, POOL_ID, INDEPENDENT_STRATEGY_ID);
    }
}
