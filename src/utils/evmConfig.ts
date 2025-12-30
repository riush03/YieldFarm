/**
 * EVM Configuration for DeFi Yield Farming dApp
 * 
 * To build for different chains, set the VITE_CHAIN environment variable:
 * 
 * VITE_CHAIN=devnet pnpm run build    (for development - default)
 * VITE_CHAIN=mainnet pnpm run build   (for production)
 */

import metadata from '../metadata.json';

const targetChainName = import.meta.env.VITE_CHAIN || 'devnet';

// Find the chain configuration by network name
const evmConfig = metadata.chains.find(chain => chain.network === targetChainName);

if (!evmConfig) {
  throw new Error(`Chain '${targetChainName}' not found in metadata.json`);
}

// Extract contract information
const rewardTokenContract = evmConfig.contracts.find(c => c.contractName === 'RewardToken');
const stakeTokenContract = evmConfig.contracts.find(c => c.contractName === 'StakeToken');
const stakingPoolContract = evmConfig.contracts.find(c => c.contractName === 'StakingPool');

if (!rewardTokenContract || !stakeTokenContract || !stakingPoolContract) {
  throw new Error('Required contracts not found in metadata.json');
}

// Export chain configuration
export const selectedChain = evmConfig;
export const chainId = parseInt(evmConfig.chainId);
export const rpcUrl = evmConfig.rpc_url;

// Export contract addresses
export const REWARD_TOKEN_ADDRESS = rewardTokenContract.address as `0x${string}`;
export const STAKE_TOKEN_ADDRESS = stakeTokenContract.address as `0x${string}`;
export const STAKING_POOL_ADDRESS = stakingPoolContract.address as `0x${string}`;

// Export contract ABIs
export const REWARD_TOKEN_ABI = rewardTokenContract.abi;
export const STAKE_TOKEN_ABI = stakeTokenContract.abi;
export const STAKING_POOL_ABI = stakingPoolContract.abi;

// Chain configuration for wagmi
export const chainConfig = {
  id: chainId,
  name: evmConfig.network,
  network: evmConfig.network,
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: { http: [rpcUrl] },
    public: { http: [rpcUrl] },
  },
} as const;
