// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/staking/IStakingStorage.sol"; // V1 for routing
import "./interfaces/staking/IStakingStorageV2.sol";
import "./interfaces/staking/IStakingVaultV2.sol";
import "./interfaces/staking/StakingErrors.sol";
import "./lib/Flags.sol";
import "./StakingFlags.sol";

uint16 constant EMPTY_FLAGS = 0;

contract StakingVaultV2 is
    IStakingVaultV2,
    ReentrancyGuard,
    AccessControl,
    Pausable,
    StakingErrors
{
    using SafeERC20 for IERC20;
    using Flags for uint16;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant CLAIM_CONTRACT_ROLE =
        keccak256("CLAIM_CONTRACT_ROLE");
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    // Immutable references
    IStakingStorage public immutable stakingStorageV1;
    IStakingStorageV2 public immutable stakingStorageV2;
    IERC20 public immutable token;

    uint8 public constant VERSION = 2;

    // Events
    event Staked(
        address indexed staker,
        bytes32 stakeId,
        uint128 amount,
        uint16 indexed stakeDay,
        uint16 indexed daysLock,
        uint16 flags
    );

    event Unstaked(
        address indexed staker,
        bytes32 indexed stakeId,
        uint16 indexed unstakeDay,
        uint128 amount
    );

    event EmergencyRecover(address token, address to, uint256 amount);

    constructor(
        IERC20 _token,
        address _storageV1,
        address _storageV2,
        address _multisig,
        address _manager
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
        _grantRole(MANAGER_ROLE, _manager);
        _grantRole(MULTISIG_ROLE, _multisig);

        token = _token;
        stakingStorageV1 = IStakingStorage(_storageV1);
        stakingStorageV2 = IStakingStorageV2(_storageV2);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                        CORE STAKING FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Stake tokens with timelock. All new stakes are V2.
     */
    function stake(
        uint128 amount,
        uint16 daysLock
    ) external whenNotPaused nonReentrant returns (bytes32 stakeId) {
        require(amount > 0, InvalidAmount());

        address staker = msg.sender;
        token.safeTransferFrom(staker, address(this), amount);

        uint32 counter = uint32(
            stakingStorageV2.getStakerInfo(staker).stakesCounter
        );

        stakeId = _generateStakeId(staker, counter, VERSION);

        stakingStorageV2.createStake(
            stakeId,
            staker,
            amount,
            daysLock,
            EMPTY_FLAGS
        );

        emit Staked(
            staker,
            stakeId,
            amount,
            _getCurrentDay(),
            daysLock,
            EMPTY_FLAGS
        );
    }

    /**
     * @notice Unstake matured tokens from either V1 or V2 storage.
     */
    function unstake(bytes32 stakeId) public whenNotPaused nonReentrant {
        require(
            _validateUnstake(stakeId, msg.sender),
            "StakingVault: Unstake validation failed"
        );
        _executeUnstake(stakeId, msg.sender);
    }

    /**
     * @notice Unstake multiple matured tokens in a single transaction. Skips any invalid stakes.
     */
    function batchUnstake(bytes32[] calldata stakeIds) external nonReentrant {
        uint256 length = stakeIds.length;
        address staker = msg.sender;
        require(length > 0 && length < 100, LimitTooLarge(1, 100));
        for (uint256 i = 0; i < length; i++) {
            if (_validateUnstake(stakeIds[i], staker)) {
                _executeUnstake(stakeIds[i], staker);
            }
        }
    }

    /**
     * @notice Checks which stake IDs from a given array are valid to be unstaked by the caller.
     * @return failedIds An array of stake IDs that cannot be unstaked.
     */
    function canUnstake(
        bytes32[] calldata stakeIds
    ) external view returns (bytes32[] memory failedIds) {
        bytes32[] memory _failedIds = new bytes32[](stakeIds.length);
        uint256 failedCount = 0;
        for (uint256 i = 0; i < stakeIds.length; i++) {
            if (!_validateUnstake(stakeIds[i], msg.sender)) {
                _failedIds[failedCount] = stakeIds[i];
                failedCount++;
            }
        }
        // Resize the array to the actual number of failed IDs
        assembly {
            mstore(_failedIds, failedCount)
        }
        return _failedIds;
    }

    // ═══════════════════════════════════════════════════════════════════
    //                        INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    function _executeUnstake(bytes32 stakeId, address owner) internal {
        uint8 version = getVersionFromId(stakeId);
        uint128 amount;
        if (version == 0) {
            amount = stakingStorageV1.getStake(stakeId).amount;
            stakingStorageV1.removeStake(owner, stakeId);
        } else {
            amount = stakingStorageV2.getStake(stakeId).amount;
            stakingStorageV2.removeStake(owner, stakeId);
        }

        token.safeTransfer(owner, amount);
        emit Unstaked(owner, stakeId, _getCurrentDay(), amount);
    }

    function _validateUnstake(
        bytes32 stakeId,
        address owner
    ) internal view returns (bool) {
        if (getStakerFromId(stakeId) != owner) {
            return false;
        }

        uint8 version = getVersionFromId(stakeId);
        IStakingStorageV2.Stake memory _stake;

        if (version == 0) {
            IStakingStorage.Stake memory _stakeV1 = stakingStorageV1.getStake(
                stakeId
            );
            _stake = IStakingStorageV2.Stake(
                _stakeV1.amount,
                _stakeV1.stakeDay,
                _stakeV1.unstakeDay,
                _stakeV1.daysLock,
                _stakeV1.flags
            );
        } else {
            _stake = stakingStorageV2.getStake(stakeId);
        }

        if (_stake.amount == 0 || _stake.unstakeDay != 0) {
            return false;
        }

        uint16 currentDay = _getCurrentDay();
        uint16 matureDay = _stake.stakeDay + _stake.daysLock;
        if (currentDay < matureDay) {
            return false;
        }

        return true;
    }

    function _generateStakeId(
        address staker,
        uint32 counter,
        uint8 version
    ) internal pure returns (bytes32) {
        return
            bytes32(
                (uint256(uint160(staker)) << 96) |
                    (uint256(counter) << 8) |
                    version
            );
    }

    // ═══════════════════════════════════════════════════════════════════
    //                        VIEW/HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    function getStake(
        bytes32 stakeId
    ) external view override returns (IStakingStorage.Stake memory) {
        uint8 version = getVersionFromId(stakeId);
        if (version == 0) {
            return stakingStorageV1.getStake(stakeId);
        } else {
            IStakingStorageV2.Stake memory stakeV2 = stakingStorageV2.getStake(
                stakeId
            );
            return
                IStakingStorage.Stake(
                    stakeV2.amount,
                    stakeV2.stakeDay,
                    stakeV2.unstakeDay,
                    stakeV2.daysLock,
                    stakeV2.flags
                );
        }
    }

    function getStakerFromId(
        bytes32 stakeId
    ) public pure override returns (address) {
        return address(uint160(uint256(stakeId) >> 96));
    }

    function getVersionFromId(
        bytes32 stakeId
    ) public pure override returns (uint8) {
        return uint8(uint256(stakeId) & 0xff);
    }

    function getCounterFromId(
        bytes32 stakeId
    ) public pure override returns (uint32) {
        return uint32((uint256(stakeId) >> 8) & ((1 << 32) - 1));
    }

    function _getCurrentDay() internal view returns (uint16) {
        return uint16(block.timestamp / 1 days);
    }

    /**
     * @notice Stake tokens from claim contract
     * @dev This function is used to stake tokens from the claim contract
     * @dev Tokens are already transferred from the claim contract to the staking vault
     * @param staker Address of the staker
     * @param amount Amount to stake
     * @param daysLock Timelock period in days
     * @return stakeId Unique identifier for the stake
     */
    function stakeFromClaim(
        address staker,
        uint128 amount,
        uint16 daysLock
    )
        external
        whenNotPaused
        onlyRole(CLAIM_CONTRACT_ROLE)
        returns (bytes32 stakeId)
    {
        require(amount > 0, InvalidAmount());

        uint16 flags = Flags.set(EMPTY_FLAGS, StakingFlags.IS_FROM_CLAIM_BIT);

        uint32 counter = uint32(
            stakingStorageV2.getStakerInfo(staker).stakesCounter
        );
        stakeId = _generateStakeId(staker, counter, VERSION);
        stakingStorageV2.createStake(stakeId, staker, amount, daysLock, flags);

        emit Staked(staker, stakeId, amount, _getCurrentDay(), daysLock, flags);
    }

    function pause() external onlyRole(MANAGER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(MANAGER_ROLE) {
        _unpause();
    }

    function emergencyRecover(
        IERC20 token_,
        uint256 amount
    ) external onlyRole(MULTISIG_ROLE) {
        token_.safeTransfer(msg.sender, amount);
        emit EmergencyRecover(address(token_), msg.sender, amount);
    }
}
