// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RewardToken
 * @dev ERC20 token used for distributing rewards to stakers
 */
contract RewardToken is ERC20, Ownable {
    /**
     * @dev Initialize the RewardToken with initial supply
     */
    constructor() ERC20("Reward Token", "RWD") Ownable(msg.sender) {
        // Mint initial supply of 1,000,000 tokens to deployer
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }

    /**
     * @dev Mint new reward tokens (only owner)
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Burn tokens from caller's balance
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
