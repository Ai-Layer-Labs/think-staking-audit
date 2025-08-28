// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./StrategiesRegistry.sol";
import "../interfaces/reward/IRewardStrategy.sol";
import "../interfaces/reward/RewardErrors.sol";

/**
 * @title FundingManager
 * @author @Tudmotu & Gemini
 * @notice An abstract contract to manage funding for PRE_FUNDED strategies.
 * @dev Intended to be inherited by RewardManager. It handles deposits and withdrawals for strategy-specific budgets.
 */
contract FundingManager is AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    StrategiesRegistry public immutable strategiesRegistry;

    // Balance tracking for PRE_FUNDED direct strategies
    mapping(uint256 => uint256) public strategyBalances;

    event StrategyFunded(uint256 indexed strategyId, uint256 amount);
    event StrategyWithdrawn(uint256 indexed strategyId, uint256 amount);

    constructor(
        address admin,
        address manager,
        address multisig,
        StrategiesRegistry _strategiesRegistry
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MANAGER_ROLE, manager);
        _grantRole(MULTISIG_ROLE, multisig);
        strategiesRegistry = _strategiesRegistry;
    }

    /**
     * @notice Deposits funds for a PRE_FUNDED direct reward strategy.
     * @dev The caller must have pre-approved this contract to spend the tokens.
     * @param _strategyId The ID of the strategy to fund.
     * @param _amount The amount of reward tokens to deposit.
     */
    function fundStrategy(
        uint256 _strategyId,
        uint256 _amount
    ) external onlyRole(MANAGER_ROLE) {
        address strategyAddress = strategiesRegistry.getStrategyAddress(
            _strategyId
        );
        require(
            strategyAddress != address(0),
            RewardErrors.StrategyNotExist(_strategyId)
        );

        IRewardStrategy strategy = IRewardStrategy(strategyAddress);

        require(_amount > 0, RewardErrors.AmountMustBeGreaterThanZero());

        address rewardToken = strategy.getRewardToken();

        strategyBalances[_strategyId] += _amount;
        IERC20(rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        emit StrategyFunded(_strategyId, _amount);
    }

    function withdrawStrategy(
        uint256 _strategyId,
        uint256 _amount,
        address _to
    ) external onlyRole(MULTISIG_ROLE) {
        _decreaseStrategyBalance(_strategyId, _amount);
        address rewardToken = IRewardStrategy(
            strategiesRegistry.getStrategyAddress(_strategyId)
        ).getRewardToken();

        IERC20(rewardToken).safeTransfer(_to, _amount);

        emit StrategyWithdrawn(_strategyId, _amount);
    }

    function transferStrategyBalance(
        uint256 _fromStrategyId,
        uint256 _toStrategyId,
        uint256 _amount
    ) external onlyRole(MANAGER_ROLE) {
        // require they have the same reward token
        address fromStrategyAddress = strategiesRegistry.getStrategyAddress(
            _fromStrategyId
        );
        address fromRewardToken = IRewardStrategy(fromStrategyAddress)
            .getRewardToken();
        address toStrategyAddress = strategiesRegistry.getStrategyAddress(
            _toStrategyId
        );
        address toRewardToken = IRewardStrategy(toStrategyAddress)
            .getRewardToken();

        require(fromRewardToken == toRewardToken, "Different reward tokens");

        _decreaseStrategyBalance(_fromStrategyId, _amount);
        _increaseStrategyBalance(_toStrategyId, _amount);
    }

    /**
     * @dev Internal function to check balance and withdraw funds for a reward payment.
     * @param _strategyId The ID of the strategy.
     * @param _amount The amount to withdraw.
     */
    function _decreaseStrategyBalance(
        uint256 _strategyId,
        uint256 _amount
    ) internal {
        uint256 currentBalance = strategyBalances[_strategyId];
        require(
            currentBalance >= _amount,
            RewardErrors.InsufficientStrategyBalance()
        );
        strategyBalances[_strategyId] = currentBalance - _amount;
    }

    function _increaseStrategyBalance(
        uint256 _strategyId,
        uint256 _amount
    ) internal {
        strategyBalances[_strategyId] += _amount;
    }
}
