// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title StakingPool
 * @dev DeFi yield farming contract with automatic reward calculation
 */
contract StakingPool is Ownable, ReentrancyGuard {
    // ERC20 token interfaces
    IERC20 public stakeToken;
    IERC20 public rewardToken;

    // Reward configuration
    uint256 public rewardRatePerSecond; // Tokens per second per staked token (scaled by 1e18)

    // Staking state
    uint256 public totalStaked;
    uint256 public lastRewardUpdate;

    // User staking information
    struct UserStake {
        uint256 amount; // Amount of tokens staked
        uint256 rewardDebt; // Accumulated rewards already claimed
        uint256 lastStakeTime; // Timestamp of last stake/claim action
    }

    mapping(address => UserStake) public userStakes;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRate);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    /**
     * @dev Initialize the staking pool
     * @param _stakeToken Address of the token to stake
     * @param _rewardToken Address of the reward token
     * @param _rewardRatePerSecond Initial reward rate (tokens per second, scaled by 1e18)
     */
    constructor(
        address _stakeToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) Ownable(msg.sender) {
        require(_stakeToken != address(0), "Invalid stake token address");
        require(_rewardToken != address(0), "Invalid reward token address");

        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        lastRewardUpdate = block.timestamp;
    }

    /**
     * @dev Stake tokens in the pool
     * @param amount Amount of tokens to stake
     */
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Stake amount must be greater than 0");

        // Claim any pending rewards first
        _claimRewards();

        // Transfer tokens from user to contract
        require(
            stakeToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        // Update user stake
        userStakes[msg.sender].amount += amount;
        userStakes[msg.sender].lastStakeTime = block.timestamp;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Withdraw staked tokens
     * @param amount Amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(
            userStakes[msg.sender].amount >= amount,
            "Insufficient staked balance"
        );

        // Claim any pending rewards first
        _claimRewards();

        // Update user stake
        userStakes[msg.sender].amount -= amount;
        totalStaked -= amount;

        // Transfer tokens back to user
        require(stakeToken.transfer(msg.sender, amount), "Token transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Claim accumulated rewards
     */
    function claimRewards() external nonReentrant {
        _claimRewards();
    }

    /**
     * @dev Internal function to claim rewards
     */
    function _claimRewards() internal {
        uint256 reward = getRewardBalance(msg.sender);

        if (reward > 0) {
            // Reset reward debt
            userStakes[msg.sender].rewardDebt = 0;
            userStakes[msg.sender].lastStakeTime = block.timestamp;

            // Transfer reward tokens to user
            require(
                rewardToken.transfer(msg.sender, reward),
                "Reward transfer failed"
            );

            emit RewardsClaimed(msg.sender, reward);
        }
    }

    /**
     * @dev Get pending reward balance for a user
     * @param user Address of the user
     * @return Pending reward amount
     */
    function getRewardBalance(address user) public view returns (uint256) {
        UserStake memory userStake = userStakes[user];

        if (userStake.amount == 0) {
            return 0;
        }

        // Calculate time elapsed since last update
        uint256 timeElapsed = block.timestamp - userStake.lastStakeTime;

        // Calculate reward: (staked amount * reward rate * time elapsed) / 1e18
        uint256 pendingReward = (userStake.amount *
            rewardRatePerSecond *
            timeElapsed) / 1e18;

        return pendingReward;
    }

    /**
     * @dev Get user's staked amount
     * @param user Address of the user
     * @return Amount of tokens staked
     */
    function getStakedAmount(address user) external view returns (uint256) {
        return userStakes[user].amount;
    }

    /**
     * @dev Update the reward rate (only owner)
     * @param newRate New reward rate (tokens per second, scaled by 1e18)
     */
    function updateRewardRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Reward rate must be greater than 0");
        rewardRatePerSecond = newRate;
        emit RewardRateUpdated(newRate);
    }

    /**
     * @dev Emergency withdraw without claiming rewards
     * Allows users to withdraw their stake in case of emergency
     */
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = userStakes[msg.sender].amount;
        require(amount > 0, "No staked balance");

        // Reset user stake
        userStakes[msg.sender].amount = 0;
        userStakes[msg.sender].rewardDebt = 0;
        totalStaked -= amount;

        // Transfer tokens back to user
        require(stakeToken.transfer(msg.sender, amount), "Token transfer failed");

        emit EmergencyWithdraw(msg.sender, amount);
    }

    /**
     * @dev Withdraw reward tokens from contract (only owner)
     * Allows owner to withdraw excess reward tokens
     * @param amount Amount of reward tokens to withdraw
     */
    function withdrawRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(
            rewardToken.transfer(msg.sender, amount),
            "Reward transfer failed"
        );
    }

    /**
     * @dev Get total staked amount in the pool
     * @return Total amount of tokens staked
     */
    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }
}
