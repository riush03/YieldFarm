// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/RewardToken.sol";
import "../src/StakeToken.sol";
import "../src/StakingPool.sol";

contract StakingPoolTest is Test {
    RewardToken public rewardToken;
    StakeToken public stakeToken;
    StakingPool public stakingPool;

    address public owner;
    address public user1;
    address public user2;

    uint256 public constant INITIAL_STAKE_BALANCE = 1000 * 10 ** 18; // 1000 tokens
    uint256 public constant INITIAL_REWARD_BALANCE = 100_000 * 10 ** 18; // 100,000 tokens
    uint256 public constant REWARD_RATE = 1e18; // 1 token per second

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        // Deploy contracts
        rewardToken = new RewardToken();
        stakeToken = new StakeToken();
        stakingPool = new StakingPool(
            address(stakeToken),
            address(rewardToken),
            REWARD_RATE
        );

        // Distribute stake tokens to users
        stakeToken.transfer(user1, INITIAL_STAKE_BALANCE);
        stakeToken.transfer(user2, INITIAL_STAKE_BALANCE);

        // Transfer reward tokens to staking pool
        rewardToken.transfer(address(stakingPool), INITIAL_REWARD_BALANCE);

        // Approve staking pool to spend stake tokens
        vm.prank(user1);
        stakeToken.approve(address(stakingPool), type(uint256).max);

        vm.prank(user2);
        stakeToken.approve(address(stakingPool), type(uint256).max);
    }

    // Test: Basic staking functionality
    function testStake() public {
        uint256 stakeAmount = 100 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        assertEq(stakingPool.getStakedAmount(user1), stakeAmount);
        assertEq(stakingPool.getTotalStaked(), stakeAmount);
    }

    // Test: Multiple users staking
    function testMultipleUsersStake() public {
        uint256 stakeAmount1 = 100 * 10 ** 18;
        uint256 stakeAmount2 = 200 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount1);

        vm.prank(user2);
        stakingPool.stake(stakeAmount2);

        assertEq(stakingPool.getStakedAmount(user1), stakeAmount1);
        assertEq(stakingPool.getStakedAmount(user2), stakeAmount2);
        assertEq(stakingPool.getTotalStaked(), stakeAmount1 + stakeAmount2);
    }

    // Test: Reward calculation
    function testRewardCalculation() public {
        uint256 stakeAmount = 100 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        // Fast forward 10 seconds
        vm.warp(block.timestamp + 10);

        // Expected reward: 100 * 1e18 * 10 / 1e18 = 1000 tokens
        uint256 expectedReward = 1000 * 10 ** 18;
        uint256 actualReward = stakingPool.getRewardBalance(user1);

        assertEq(actualReward, expectedReward);
    }

    // Test: Claim rewards
    function testClaimRewards() public {
        uint256 stakeAmount = 100 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        // Fast forward 10 seconds
        vm.warp(block.timestamp + 10);

        uint256 expectedReward = 1000 * 10 ** 18;
        uint256 initialBalance = rewardToken.balanceOf(user1);

        vm.prank(user1);
        stakingPool.claimRewards();

        uint256 finalBalance = rewardToken.balanceOf(user1);
        assertEq(finalBalance - initialBalance, expectedReward);
    }

    // Test: Withdraw staked tokens
    function testWithdraw() public {
        uint256 stakeAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 50 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        vm.prank(user1);
        stakingPool.withdraw(withdrawAmount);

        assertEq(
            stakingPool.getStakedAmount(user1),
            stakeAmount - withdrawAmount
        );
        assertEq(stakingPool.getTotalStaked(), stakeAmount - withdrawAmount);
    }

    // Test: Withdraw with reward claim
    function testWithdrawWithRewardClaim() public {
        uint256 stakeAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 50 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        // Fast forward 10 seconds
        vm.warp(block.timestamp + 10);

        uint256 expectedReward = 1000 * 10 ** 18;
        uint256 initialBalance = rewardToken.balanceOf(user1);

        vm.prank(user1);
        stakingPool.withdraw(withdrawAmount);

        uint256 finalBalance = rewardToken.balanceOf(user1);
        // Should receive both withdrawn tokens and rewards
        assertEq(finalBalance - initialBalance, expectedReward);
    }

    // Test: Emergency withdraw
    function testEmergencyWithdraw() public {
        uint256 stakeAmount = 100 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        // Fast forward 10 seconds (rewards accumulate but are not claimed)
        vm.warp(block.timestamp + 10);

        uint256 initialBalance = stakeToken.balanceOf(user1);

        vm.prank(user1);
        stakingPool.emergencyWithdraw();

        uint256 finalBalance = stakeToken.balanceOf(user1);
        // Should only receive staked tokens, not rewards
        assertEq(finalBalance - initialBalance, stakeAmount);
        assertEq(stakingPool.getStakedAmount(user1), 0);
    }

    // Test: Update reward rate
    function testUpdateRewardRate() public {
        uint256 newRate = 2e18; // 2 tokens per second

        stakingPool.updateRewardRate(newRate);
        assertEq(stakingPool.rewardRatePerSecond(), newRate);
    }

    // Test: Only owner can update reward rate
    function testOnlyOwnerCanUpdateRewardRate() public {
        uint256 newRate = 2e18;

        vm.prank(user1);
        vm.expectRevert();
        stakingPool.updateRewardRate(newRate);
    }

    // Test: Stake zero amount reverts
    function testStakeZeroAmountReverts() public {
        vm.prank(user1);
        vm.expectRevert("Stake amount must be greater than 0");
        stakingPool.stake(0);
    }

    // Test: Withdraw more than staked reverts
    function testWithdrawMoreThanStakedReverts() public {
        uint256 stakeAmount = 100 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        vm.prank(user1);
        vm.expectRevert("Insufficient staked balance");
        stakingPool.withdraw(stakeAmount + 1);
    }

    // Test: Multiple stakes accumulate
    function testMultipleStakesAccumulate() public {
        uint256 stakeAmount1 = 50 * 10 ** 18;
        uint256 stakeAmount2 = 50 * 10 ** 18;

        vm.prank(user1);
        stakingPool.stake(stakeAmount1);

        vm.warp(block.timestamp + 5);

        vm.prank(user1);
        stakingPool.stake(stakeAmount2);

        assertEq(
            stakingPool.getStakedAmount(user1),
            stakeAmount1 + stakeAmount2
        );
    }

    // Test: Withdraw rewards by owner
    function testOwnerWithdrawRewards() public {
        uint256 withdrawAmount = 1000 * 10 ** 18;
        uint256 initialBalance = rewardToken.balanceOf(owner);

        stakingPool.withdrawRewards(withdrawAmount);

        uint256 finalBalance = rewardToken.balanceOf(owner);
        assertEq(finalBalance - initialBalance, withdrawAmount);
    }

    // Test: Concurrent staking and rewards
    function testConcurrentStakingAndRewards() public {
        uint256 stakeAmount = 100 * 10 ** 18;

        // User1 stakes
        vm.prank(user1);
        stakingPool.stake(stakeAmount);

        vm.warp(block.timestamp + 5);

        // User2 stakes
        vm.prank(user2);
        stakingPool.stake(stakeAmount);

        vm.warp(block.timestamp + 5);

        // User1 should have 5 seconds of rewards
        uint256 reward1 = stakingPool.getRewardBalance(user1);
        assertEq(reward1, 500 * 10 ** 18);

        // User2 should have 0 seconds of rewards (just staked)
        uint256 reward2 = stakingPool.getRewardBalance(user2);
        assertEq(reward2, 0);
    }
}
