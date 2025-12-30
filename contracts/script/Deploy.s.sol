// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";
import "../src/TemporaryDeployFactory.sol";

/**
 * @title Deploy Script
 * @dev Deployment script for the Yield Farming System
 * Deploys all contracts using the TemporaryDeployFactory pattern
 */
contract DeployScript is Script {
    function run() external {
        // Get private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Record logs to capture deployment events
        vm.recordLogs();

        // Deploy the factory which deploys all contracts
        TemporaryDeployFactory factory = new TemporaryDeployFactory();

        // Stop broadcasting
        vm.stopBroadcast();

        // Parse the ContractsDeployed event to get contract addresses
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 eventSignature = keccak256(
            "ContractsDeployed(address,string[],address[])"
        );

        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].topics[0] == eventSignature &&
                logs[i].emitter == address(factory)
            ) {
                // Extract deployer from indexed parameter
                address deployer = address(uint160(uint256(logs[i].topics[1])));

                // Decode dynamic arrays from event data
                (string[] memory contractNames, address[] memory contractAddresses) = abi
                    .decode(logs[i].data, (string[], address[]));

                console.log("========== Deployment Successful ==========");
                console.log("Deployer:", deployer);
                console.log("Contracts deployed:", contractNames.length);
                console.log("");

                // Log all deployed contracts
                for (uint256 j = 0; j < contractNames.length; j++) {
                    console.log(
                        string(
                            abi.encodePacked(
                                contractNames[j],
                                ": ",
                                vm.toString(contractAddresses[j])
                            )
                        )
                    );
                }

                console.log("==========================================");
                break;
            }
        }
    }
}
