// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ClaimsJournal
 * @author @Tudmotu & Gemini
 * @notice Stores all user claim history for both DIRECT and SHARED_POOL rewards.
 * @dev This contract is the single source of truth for the RewardManager to determine
 *      if a user is eligible for a future claim based on their past actions.
 *      It knows nothing about reward logic; it is a simple, append-only ledger.
 */
contract ClaimsJournal is AccessControl {
    enum LayerClaimType {
        NONE,
        NORMAL,
        EXCLUSIVE,
        SEMI_EXCLUSIVE
    }

    event LayerStateUpdated(
        address indexed user,
        uint32 indexed poolId,
        uint8 indexed layerId,
        LayerClaimType newStateType
    );

    event DirectClaimRecorded(
        bytes32 indexed stakeId,
        uint32 indexed strategyId,
        uint256 claimDay
    );

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    // Tracks the state of a user's claim on a specific layer of a pool.
    // User Address => Pool ID => Layer ID => Claim Type
    mapping(address userAddress => mapping(uint32 poolId => mapping(uint8 layerId => LayerClaimType)))
        public layerClaimState;

    // Tracks the last day a reward was claimed for a specific stake and a DIRECT strategy.
    // Stake ID => Strategy ID => Day
    mapping(bytes32 stakeId => mapping(uint32 strategyId => uint16 claimDay))
        public claimDates;

    constructor(address _admin, address _rewardManager) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MANAGER_ROLE, _rewardManager);
    }

    /**
     * @notice Records a claim, updating the state for the given user, pool, and strategy.
     * @dev To be called ONLY by the RewardManager after a successful reward payment.
     */
    function recordClaim(
        address _user,
        uint32 _poolId,
        uint8 _layerId,
        uint32 _strategyId,
        bytes32 _stakeId,
        LayerClaimType _claimType,
        bool _isPoolSizeDependent,
        uint16 _claimDay
    ) external onlyRole(MANAGER_ROLE) {
        LayerClaimType currentLayerState = layerClaimState[_user][_poolId][
            _layerId
        ];

        if (_claimType == LayerClaimType.EXCLUSIVE) {
            require(
                currentLayerState == LayerClaimType.NONE,
                "CJ: Layer has claims"
            );
        } else {
            // NORMAL or SEMI_EXCLUSIVE
            require(
                currentLayerState != LayerClaimType.EXCLUSIVE,
                "CJ: Layer locked by exclusive claim"
            );
            if (_claimType == LayerClaimType.SEMI_EXCLUSIVE) {
                require(
                    currentLayerState != LayerClaimType.SEMI_EXCLUSIVE,
                    "CJ: Layer has semi-exclusive claim"
                );
            }
        }

        // Only update state if it's the first stackable/semi-exclusive claim
        if (currentLayerState == LayerClaimType.NONE) {
            layerClaimState[_user][_poolId][_layerId] = _claimType;
            emit LayerStateUpdated(_user, _poolId, _layerId, _claimType);
        } else if (_claimType == LayerClaimType.EXCLUSIVE) {
            // Redundant but safe
            layerClaimState[_user][_poolId][_layerId] = _claimType;
            emit LayerStateUpdated(_user, _poolId, _layerId, _claimType);
        }

        claimDates[_stakeId][_strategyId] = _claimDay;
        emit DirectClaimRecorded(_stakeId, _strategyId, _claimDay);
    }

    // ===================================================================
    //                           VIEW FUNCTIONS
    // ===================================================================

    function getLayerClaimState(
        address _user,
        uint32 _poolId,
        uint8 _layerId
    ) external view returns (LayerClaimType) {
        return layerClaimState[_user][_poolId][_layerId];
    }

    function getLastClaimDay(
        bytes32 _stakeId,
        uint32 _strategyId
    ) external view returns (uint16) {
        return claimDates[_stakeId][_strategyId];
    }
}
