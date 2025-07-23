// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/reward/IRewardStrategy.sol";
import "../interfaces/reward/IEnums.sol";
import "../interfaces/reward/RewardErrors.sol";

contract RewardBookkeeper is RewardErrors, AccessControl {
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");

    bool private _controllerInitialized;

    struct GrantedReward {
        uint128 amount;
        uint32 grantedAt;
        uint32 poolId;
        uint32 strategyId;
        uint16 strategyVersion;
        bool claimed;
    }

    mapping(address user => GrantedReward[]) private _userRewards;
    mapping(address user => uint256 nextClaimableIndex)
        private _nextClaimableIndex;

    event RewardGranted(
        address indexed user,
        uint256 indexed strategyId,
        uint32 indexed poolId,
        uint256 amount,
        uint16 strategyVersion
    );
    event RewardClaimed(
        address indexed user,
        uint256 indexed rewardIndex,
        uint256 amount
    );
    event BatchRewardsClaimed(
        address indexed user,
        uint256 totalAmount,
        uint256 rewardCount
    );

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor(address admin, address manager) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MANAGER_ROLE, manager);
    }

    function initController(
        address controller
    ) external onlyRole(MANAGER_ROLE) {
        require(!_controllerInitialized, ControllerAlreadySet());
        _controllerInitialized = true;
        _grantRole(CONTROLLER_ROLE, controller);
    }

    function grantReward(
        address user,
        uint256 strategyId,
        uint16 strategyVersion,
        uint256 amount,
        uint32 poolId
    ) external onlyRole(CONTROLLER_ROLE) {
        _userRewards[user].push(
            GrantedReward({
                amount: uint128(amount),
                grantedAt: uint32(block.timestamp),
                poolId: poolId,
                strategyId: uint16(strategyId),
                strategyVersion: strategyVersion,
                claimed: false
            })
        );
        emit RewardGranted(user, strategyId, poolId, amount, strategyVersion);
    }

    function markRewardClaimed(
        address user,
        uint256 rewardIndex
    ) external onlyRole(CONTROLLER_ROLE) {
        GrantedReward storage reward = _userRewards[user][rewardIndex];
        require(!reward.claimed, RewardAlreadyClaimed(rewardIndex));
        reward.claimed = true;
        emit RewardClaimed(user, rewardIndex, reward.amount);
    }

    function batchMarkClaimed(
        address user,
        uint256[] calldata rewardIndices
    ) external onlyRole(CONTROLLER_ROLE) {
        uint256 totalAmount = 0;
        uint256 claimedCount = 0;
        for (uint256 i = 0; i < rewardIndices.length; i++) {
            uint256 rewardIndex = rewardIndices[i];
            GrantedReward storage reward = _userRewards[user][rewardIndex];
            if (!reward.claimed) {
                reward.claimed = true;
                totalAmount += reward.amount;
                claimedCount++;
            }
        }
        emit BatchRewardsClaimed(user, totalAmount, claimedCount);
    }

    function getUserRewards(
        address user
    ) external view returns (GrantedReward[] memory) {
        return _userRewards[user];
    }

    function getUserClaimableAmount(
        address user
    ) external view returns (uint256) {
        uint256 claimableAmount = 0;
        for (uint256 i = 0; i < _userRewards[user].length; i++) {
            if (!_userRewards[user][i].claimed)
                claimableAmount += _userRewards[user][i].amount;
        }
        return claimableAmount;
    }

    function getUserClaimableRewards(
        address user
    ) external view returns (GrantedReward[] memory, uint256[] memory) {
        uint256 totalRewards = _userRewards[user].length;
        uint256 startIndex = _nextClaimableIndex[user];

        if (startIndex >= totalRewards)
            return (new GrantedReward[](0), new uint256[](0));

        uint256 maxPossible = totalRewards - startIndex;
        GrantedReward[] memory tempRewards = new GrantedReward[](maxPossible);
        uint256[] memory tempIndices = new uint256[](maxPossible);
        uint256 count = 0;

        for (uint256 i = startIndex; i < totalRewards; i++) {
            if (!_userRewards[user][i].claimed) {
                tempRewards[count] = _userRewards[user][i];
                tempIndices[count] = i;
                count++;
            }
        }

        GrantedReward[] memory claimableRewards = new GrantedReward[](count);
        uint256[] memory claimableIndices = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            claimableRewards[i] = tempRewards[i];
            claimableIndices[i] = tempIndices[i];
        }

        return (claimableRewards, claimableIndices);
    }

    function getUserPoolRewards(
        address user,
        uint32 poolId
    ) external view returns (GrantedReward[] memory) {
        uint256 poolRewardCount = 0;
        for (uint256 i = 0; i < _userRewards[user].length; i++) {
            if (_userRewards[user][i].poolId == poolId) poolRewardCount++;
        }

        GrantedReward[] memory poolRewards = new GrantedReward[](
            poolRewardCount
        );
        uint256 counter = 0;
        for (uint256 i = 0; i < _userRewards[user].length; i++) {
            if (_userRewards[user][i].poolId == poolId) {
                poolRewards[counter] = _userRewards[user][i];
                counter++;
            }
        }
        return poolRewards;
    }

    function getUserRewardsPaginated(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (GrantedReward[] memory) {
        uint256 totalRewards = _userRewards[user].length;
        if (offset >= totalRewards) return new GrantedReward[](0);

        uint256 end = offset + limit;
        if (end > totalRewards) end = totalRewards;

        GrantedReward[] memory paginatedRewards = new GrantedReward[](
            end - offset
        );
        for (uint256 i = offset; i < end; i++) {
            paginatedRewards[i - offset] = _userRewards[user][i];
        }
        return paginatedRewards;
    }

    function updateNextClaimableIndex(
        address user
    ) external onlyRole(CONTROLLER_ROLE) {
        uint256 numberOfRewards = _userRewards[user].length;
        uint256 currentIndex = _nextClaimableIndex[user];

        for (uint256 i = currentIndex; i < numberOfRewards; i++) {
            if (!_userRewards[user][i].claimed) {
                _nextClaimableIndex[user] = i;
                return;
            }
        }
        _nextClaimableIndex[user] = numberOfRewards;
    }
}
