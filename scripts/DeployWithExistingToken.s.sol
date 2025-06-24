// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/StakingStorage.sol";
import "../src/StakingVault.sol";

/**
 * @title DeployWithExistingToken
 * @notice Deployment script for existing token deployments (like THINK token)
 */
contract DeployWithExistingToken is Script {
    function run() external {
        // Read from environment variables
        address admin = vm.envAddress("ADMIN");
        address manager = vm.envAddress("MANAGER");
        address multisig = vm.envAddress("MULTISIG");
        address token = vm.envAddress("TOKEN");

        require(admin != address(0), "ADMIN not set");
        require(manager != address(0), "MANAGER not set");
        require(multisig != address(0), "MULTISIG not set");
        require(token != address(0), "TOKEN not set");

        vm.startBroadcast();

        console.log("Deploying with configuration:");
        console.log("Token:    ", token);
        console.log("Admin:    ", multisig);
        console.log("Manager:  ", manager);

        // 1. Deploy StakingStorage
        StakingStorage stakingStorage = new StakingStorage(admin, manager);
        console.log("StakingStorage deployed at:", address(stakingStorage));

        // 2. Deploy StakingVault
        StakingVault stakingVault = new StakingVault(
            IERC20(token),
            address(stakingStorage),
            admin,
            manager
        );
        console.log("StakingVault deployed at:", address(stakingVault));

        // 3. Grant CONTROLLER_ROLE to vault
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
        console.log("forge verify-contract ", address(stakingStorage), " \\");
        console.log("  src/StakingStorage.sol:StakingStorage \\");
        console.log("  --chain sepolia \\");
        console.log("  --compiler-version v0.8.30 \\");
        console.log("  --num-of-optimizations 200 \\");
        console.log(
            "  --etherscan-api-key ",
            vm.envString("ETHERSCAN_API_KEY"),
            " \\"
        );
        console.log(
            "  --constructor-args $(cast abi-encode 'constructor(address,address)' %s %s)",
            admin,
            manager
        );

        console.log("\nStakingVault verification:");
        console.log("forge verify-contract ", address(stakingVault), " \\");
        console.log("  src/StakingVault.sol:StakingVault \\");
        console.log("  --chain sepolia \\");
        console.log("  --compiler-version v0.8.30 \\");
        console.log("  --num-of-optimizations 200 \\");
        console.log(
            "  --etherscan-api-key ",
            vm.envString("ETHERSCAN_API_KEY"),
            " \\"
        );
        string memory constructorArgs = string.concat(
            "--constructor-args $(cast abi-encode 'constructor(address,address,address,address)' ",
            vm.toString(token),
            " ",
            vm.toString(address(stakingStorage)),
            " ",
            vm.toString(admin),
            " ",
            vm.toString(manager),
            ")"
        );
        console.log(constructorArgs);
    }
}

// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.30;

// import "forge-std/Script.sol";
// import "forge-std/console.sol";
// import "../src/StakingStorage.sol";
// import "../src/StakingVault.sol";

// contract DeployWithExistingToken is Script {
//     function run() external {
//         address admin = vm.envAddress("ADMIN");
//         address manager = vm.envAddress("MANAGER");
//         address multisig = vm.envAddress("MULTISIG");
//         address token = vm.envAddress("TOKEN");

//         require(admin != address(0), "ADMIN not set");
//         require(manager != address(0), "MANAGER not set");
//         require(multisig != address(0), "MULTISIG not set");
//         require(token != address(0), "TOKEN not set");

//         vm.startBroadcast();

//         console.log("Deploying with configuration:");
//         console.log("Token:    ", token);
//         console.log("Admin:    ", multisig);
//         console.log("Manager:  ", manager);

//         // 1. Deploy StakingStorage
//         StakingStorage stakingStorage = new StakingStorage(admin, manager);
//         console.log("StakingStorage deployed at:", address(stakingStorage));

//         // 2. Deploy StakingVault
//         StakingVault stakingVault = new StakingVault(
//             IERC20(token),
//             address(stakingStorage),
//             admin,
//             manager
//         );
//         console.log("StakingVault deployed at:", address(stakingVault));

//         // 3. Grant CONTROLLER_ROLE to vault
//         bytes32 CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");
//         stakingStorage.grantRole(CONTROLLER_ROLE, address(stakingVault));
//         console.log("Granted CONTROLLER_ROLE to vault");

//         vm.stopBroadcast();

//         // Output for verification commands
//         console.log("\n=== VERIFICATION COMMANDS ===");
//         console.log("Export deployed addresses:");
//         console.log("export STAKING_STORAGE=", address(stakingStorage));
//         console.log("export STAKING_VAULT=", address(stakingVault));

//         // StakingStorage verification
//         console.log("\nStakingStorage verification:");
//         string memory storageVerify = string.concat(
//             "forge verify-contract ",
//             vm.toString(address(stakingStorage)),
//             " src/StakingStorage.sol:StakingStorage",
//             " --chain sepolia",
//             " --compiler-version v0.8.30",
//             " --num-of-optimizations 200",
//             " --etherscan-api-key ",
//             vm.envString("ETHERSCAN_API_KEY"),
//             " --constructor-args $(cast abi-encode 'constructor(address,address)' ",
//             vm.toString(admin),
//             " ",
//             vm.toString(manager),
//             ")"
//         );
//         console.log(storageVerify);

//         // StakingVault verification
//         console.log("\nStakingVault verification:");
//         string memory vaultVerify = string.concat(
//             "forge verify-contract ",
//             vm.toString(address(stakingVault)),
//             " src/StakingVault.sol:StakingVault",
//             " --chain sepolia",
//             " --compiler-version v0.8.30",
//             " --num-of-optimizations 200",
//             " --etherscan-api-key ",
//             vm.envString("ETHERSCAN_API_KEY"),
//             " --constructor-args $(cast abi-encode 'constructor(address,address,address,address)' ",
//             vm.toString(token),
//             " ",
//             vm.toString(address(stakingStorage)),
//             " ",
//             vm.toString(admin),
//             " ",
//             vm.toString(manager),
//             ")"
//         );
//         console.log(vaultVerify);
//     }
// }
