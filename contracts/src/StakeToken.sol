// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StakeToken
 * @dev Mock ERC20 token for testing staking functionality
 */
contract StakeToken is ERC20, Ownable {
    /**
     * @dev Initialize the StakeToken with initial supply
     */
    constructor() ERC20("Stake Token", "STK") Ownable(msg.sender) {
        // Mint initial supply of 10,000,000 tokens to deployer
        _mint(msg.sender, 10_000_000 * 10 ** 18);
    }

    /**
     * @dev Mint new tokens (only owner)
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
