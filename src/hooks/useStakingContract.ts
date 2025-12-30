import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseUnits, formatUnits } from 'viem';
import { 
  STAKING_POOL_ADDRESS, 
  STAKING_POOL_ABI,
  STAKE_TOKEN_ADDRESS,
  STAKE_TOKEN_ABI,
  REWARD_TOKEN_ADDRESS,
  REWARD_TOKEN_ABI
} from '../utils/evmConfig';

export function useStakingContract(userAddress?: `0x${string}`) {
  // Read user's staked amount
  const { data: stakedAmount, refetch: refetchStaked } = useReadContract({
    address: STAKING_POOL_ADDRESS,
    abi: STAKING_POOL_ABI,
    functionName: 'getStakedAmount',
    args: userAddress ? [userAddress] : undefined,
  });

  // Read user's pending rewards
  const { data: pendingRewards, refetch: refetchRewards } = useReadContract({
    address: STAKING_POOL_ADDRESS,
    abi: STAKING_POOL_ABI,
    functionName: 'getRewardBalance',
    args: userAddress ? [userAddress] : undefined,
  });

  // Read total staked in pool
  const { data: totalStaked, refetch: refetchTotal } = useReadContract({
    address: STAKING_POOL_ADDRESS,
    abi: STAKING_POOL_ABI,
    functionName: 'getTotalStaked',
  });

  // Read reward rate
  const { data: rewardRate } = useReadContract({
    address: STAKING_POOL_ADDRESS,
    abi: STAKING_POOL_ABI,
    functionName: 'rewardRatePerSecond',
  });

  // Read user's stake token balance
  const { data: stakeTokenBalance, refetch: refetchStakeBalance } = useReadContract({
    address: STAKE_TOKEN_ADDRESS,
    abi: STAKE_TOKEN_ABI,
    functionName: 'balanceOf',
    args: userAddress ? [userAddress] : undefined,
  });

  // Read user's reward token balance
  const { data: rewardTokenBalance, refetch: refetchRewardBalance } = useReadContract({
    address: REWARD_TOKEN_ADDRESS,
    abi: REWARD_TOKEN_ABI,
    functionName: 'balanceOf',
    args: userAddress ? [userAddress] : undefined,
  });

  // Read allowance for staking
  const { data: allowance, refetch: refetchAllowance } = useReadContract({
    address: STAKE_TOKEN_ADDRESS,
    abi: STAKE_TOKEN_ABI,
    functionName: 'allowance',
    args: userAddress ? [userAddress, STAKING_POOL_ADDRESS] : undefined,
  });

  // Write contracts
  const { writeContract: writeApprove, data: approveHash } = useWriteContract();
  const { writeContract: writeStake, data: stakeHash } = useWriteContract();
  const { writeContract: writeWithdraw, data: withdrawHash } = useWriteContract();
  const { writeContract: writeClaim, data: claimHash } = useWriteContract();

  // Wait for transactions
  const { isLoading: isApproving } = useWaitForTransactionReceipt({ hash: approveHash });
  const { isLoading: isStaking } = useWaitForTransactionReceipt({ hash: stakeHash });
  const { isLoading: isWithdrawing } = useWaitForTransactionReceipt({ hash: withdrawHash });
  const { isLoading: isClaiming } = useWaitForTransactionReceipt({ hash: claimHash });

  const approve = async (amount: string) => {
    const amountWei = parseUnits(amount, 18);
    writeApprove({
      address: STAKE_TOKEN_ADDRESS,
      abi: STAKE_TOKEN_ABI,
      functionName: 'approve',
      args: [STAKING_POOL_ADDRESS, amountWei],
    });
  };

  const stake = async (amount: string) => {
    const amountWei = parseUnits(amount, 18);
    writeStake({
      address: STAKING_POOL_ADDRESS,
      abi: STAKING_POOL_ABI,
      functionName: 'stake',
      args: [amountWei],
    });
  };

  const withdraw = async (amount: string) => {
    const amountWei = parseUnits(amount, 18);
    writeWithdraw({
      address: STAKING_POOL_ADDRESS,
      abi: STAKING_POOL_ABI,
      functionName: 'withdraw',
      args: [amountWei],
    });
  };

  const claimRewards = async () => {
    writeClaim({
      address: STAKING_POOL_ADDRESS,
      abi: STAKING_POOL_ABI,
      functionName: 'claimRewards',
    });
  };

  const refetchAll = () => {
    refetchStaked();
    refetchRewards();
    refetchTotal();
    refetchStakeBalance();
    refetchRewardBalance();
    refetchAllowance();
  };

  return {
    // Data
    stakedAmount: stakedAmount ? formatUnits(stakedAmount as bigint, 18) : '0',
    pendingRewards: pendingRewards ? formatUnits(pendingRewards as bigint, 18) : '0',
    totalStaked: totalStaked ? formatUnits(totalStaked as bigint, 18) : '0',
    rewardRate: rewardRate ? formatUnits(rewardRate as bigint, 18) : '0',
    stakeTokenBalance: stakeTokenBalance ? formatUnits(stakeTokenBalance as bigint, 18) : '0',
    rewardTokenBalance: rewardTokenBalance ? formatUnits(rewardTokenBalance as bigint, 18) : '0',
    allowance: allowance ? formatUnits(allowance as bigint, 18) : '0',
    
    // Actions
    approve,
    stake,
    withdraw,
    claimRewards,
    refetchAll,
    
    // Loading states
    isApproving,
    isStaking,
    isWithdrawing,
    isClaiming,
  };
}
