// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IStakingStorage} from "../staking/IStakingStorage.sol";

interface IRewardStrategyV2 {
    enum StrategyType {
        POOL_SIZE_INDEPENDENT, // Can calculate anytime (APR-style)
        POOL_SIZE_DEPENDENT // Requires BE calculation after pool ends - how much were staked during the pool
    }

    struct PoolData {
        uint256 weight;
        uint256 reward;
        uint16 startDay;
        uint16 endDay;
    }

    struct CalculationData {
        address staker;
        IStakingStorage.Stake stake;
        PoolData pool;
        uint16 lastClaimDay;
    }

    // --- CONFIGURATION VIEW FUNCTIONS ---

    function getName() external view returns (string memory);

    function getRewardToken() external view returns (address);

    function getStrategyType() external view returns (StrategyType);

    /**
     * @notice Calculates reward for POOL_SIZE_DEPENDENT strategies.
     */
    function calculateReward(
        CalculationData calldata calculationData,
        bytes calldata payload
    ) external view returns (uint256);
}
