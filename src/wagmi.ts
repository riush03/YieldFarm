import { http, createConfig } from 'wagmi';
import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { chainConfig } from './utils/evmConfig';

export const config = getDefaultConfig({
  appName: 'DeFi Yield Farming',
  projectId: '3fcc6bba6f1de962d911bb5b5c3dba68',
  chains: [chainConfig as any],
  transports: {
    [chainConfig.id]: http(),
  },
});
