// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/StakingStorage.sol";
import "../src/StakingVault.sol";
import "../src/Token.sol";

/**
 * @title DeployStaking
 * @notice Deployment script for the Think Token staking system
 */
contract DeployStaking is Script {
    // Configuration - Replace with actual addresses
    address constant ADMIN = 0x1234567890123456789012345678901234567890;
    address constant MANAGER = 0x2345678901234567890123456789012345678901;
    address constant MULTISIG = 0x3456789012345678901234567890123456789012;

    // Optional: Use existing token address
    address constant EXISTING_TOKEN = address(0); // Set to deployed token address or leave as 0

    function run() external {
        vm.startBroadcast();

        address tokenAddress;

        // 1. Deploy or use existing token
        if (EXISTING_TOKEN == address(0)) {
            Token token = new Token();
            tokenAddress = address(token);
            console.log("Token deployed at:", tokenAddress);
        } else {
            tokenAddress = EXISTING_TOKEN;
            console.log("Using existing token at:", tokenAddress);
        }

        // 2. Deploy StakingStorage first
        StakingStorage stakingStorage = new StakingStorage(ADMIN, MANAGER);
        console.log("StakingStorage deployed at:", address(stakingStorage));

        // 3. Deploy StakingVault
        StakingVault stakingVault = new StakingVault(
            IERC20(tokenAddress),
            address(stakingStorage),
            ADMIN,
            MANAGER
        );
        console.log("StakingVault deployed at:", address(stakingVault));

        // 4. Grant CONTROLLER_ROLE to vault in storage contract
        bytes32 CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");
        stakingStorage.grantRole(CONTROLLER_ROLE, address(stakingVault));
        console.log("Granted CONTROLLER_ROLE to vault");

        vm.stopBroadcast();


        // Output for verification commands
        console.log("\n=== VERIFICATION COMMANDS ===");
        console.log("Export deployed addresses:");
        console.log("export STAKING_STORAGE=", address(stakingStorage));
        console.log("export STAKING_VAULT=", address(stakingVault));

        console.log("\nStakingStorage verification:");
        console.log("forge verify-contract $STAKING_STORAGE \\");
        console.log("  src/StakingStorage.sol:StakingStorage \\");
        console.log("  --chain sepolia \\");
        console.log("  --compiler-version v0.8.30 \\");
        console.log("  --num-of-optimizations 200 \\");
        console.log("  --etherscan-api-key $ETHERSCAN_API_KEY \\");
        console.log(
            "  --constructor-args $(cast abi-encode 'constructor(address,address)' ",
            admin,
            ", ",
            manager,
            ")"
        );

        console.log("\nStakingVault verification:");
        console.log("forge verify-contract $STAKING_VAULT \\");
        console.log("  src/StakingVault.sol:StakingVault \\");
        console.log("  --chain sepolia \\");
        console.log("  --compiler-version v0.8.30 \\");
        console.log("  --num-of-optimizations 200 \\");
        console.log("  --etherscan-api-key $ETHERSCAN_API_KEY \\");
        console.log(
            "  --constructor-args $(cast abi-encode 'constructor(address,address,address,address)' ",
            token,
            " ",
            address(stakingStorage),
            " ",
            admin,
            " ",
            manager,
            ")"
        );
}
