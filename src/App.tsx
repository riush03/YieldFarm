import { ConnectButton } from '@rainbow-me/rainbowkit';
import { StakingCard } from './components/StakingCard';
import { PoolStats } from './components/PoolStats';

function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-green-50">
      <nav className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-purple-600 to-green-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xl">Y</span>
              </div>
              <h1 className="text-xl font-bold bg-gradient-to-r from-purple-600 to-green-600 bg-clip-text text-transparent">
                Yield Farm
              </h1>
            </div>
            <ConnectButton />
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold mb-4">
            Stake Your Tokens, Earn Rewards
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            Participate in our DeFi yield farming pool. Stake your tokens and earn passive rewards automatically.
          </p>
        </div>

        <div className="space-y-8">
          <PoolStats />
          
          <div className="flex justify-center">
            <StakingCard />
          </div>
        </div>

        <div className="mt-16 text-center">
          <div className="inline-block p-6 bg-white rounded-lg shadow-sm border">
            <h3 className="text-lg font-semibold mb-2">How It Works</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-4 text-left">
              <div className="space-y-2">
                <div className="w-8 h-8 bg-purple-100 text-purple-600 rounded-full flex items-center justify-center font-bold">
                  1
                </div>
                <h4 className="font-semibold">Connect Wallet</h4>
                <p className="text-sm text-muted-foreground">
                  Connect your Web3 wallet to get started
                </p>
              </div>
              <div className="space-y-2">
                <div className="w-8 h-8 bg-purple-100 text-purple-600 rounded-full flex items-center justify-center font-bold">
                  2
                </div>
                <h4 className="font-semibold">Stake Tokens</h4>
                <p className="text-sm text-muted-foreground">
                  Deposit your STAKE tokens into the pool
                </p>
              </div>
              <div className="space-y-2">
                <div className="w-8 h-8 bg-green-100 text-green-600 rounded-full flex items-center justify-center font-bold">
                  3
                </div>
                <h4 className="font-semibold">Earn Rewards</h4>
                <p className="text-sm text-muted-foreground">
                  Automatically earn REWARD tokens over time
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;
