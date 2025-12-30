// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./RewardToken.sol";
import "./StakeToken.sol";
import "./StakingPool.sol";

/**
 * @title TemporaryDeployFactory
 * @dev EIP-6780 factory contract for deploying the yield farming system
 * Uses self-destruct pattern to enable parameter-free bytecode sharing across chains
 */
contract TemporaryDeployFactory {
    /// @notice Emitted when all contracts are deployed
    /// @dev This event enables frontend to query deployed contracts by tx hash
    event ContractsDeployed(
        address indexed deployer,
        string[] contractNames,
        address[] contractAddresses
    );

    constructor() {
        // Deploy RewardToken
        RewardToken rewardToken = new RewardToken();

        // Deploy StakeToken
        StakeToken stakeToken = new StakeToken();

        // Deploy StakingPool with initial reward rate of 1 token per second (scaled by 1e18)
        // This means 1 token per second per staked token
        uint256 rewardRatePerSecond = 1e18; // 1 token per second
        StakingPool stakingPool = new StakingPool(
            address(stakeToken),
            address(rewardToken),
            rewardRatePerSecond
        );

        // Transfer initial reward tokens to staking pool
        // Transfer 100,000 tokens (100,000 * 10^18)
        rewardToken.transfer(address(stakingPool), 100_000 * 10 ** 18);

        // Build contract info arrays
        string[] memory contractNames = new string[](3);
        contractNames[0] = "RewardToken";
        contractNames[1] = "StakeToken";
        contractNames[2] = "StakingPool";

        address[] memory contractAddresses = new address[](3);
        contractAddresses[0] = address(rewardToken);
        contractAddresses[1] = address(stakeToken);
        contractAddresses[2] = address(stakingPool);

        // Emit event with all contract info
        emit ContractsDeployed(msg.sender, contractNames, contractAddresses);

        // Self-destruct to clean up
        selfdestruct(payable(msg.sender));
    }
}
