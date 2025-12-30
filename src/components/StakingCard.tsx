import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { useStakingContract } from '../hooks/useStakingContract';
import { useAccount } from 'wagmi';

export function StakingCard() {
  const { address } = useAccount();
  const {
    stakedAmount,
    pendingRewards,
    stakeTokenBalance,
    allowance,
    approve,
    stake,
    withdraw,
    claimRewards,
    isApproving,
    isStaking,
    isWithdrawing,
    isClaiming,
    refetchAll,
  } = useStakingContract(address);

  const [stakeAmount, setStakeAmount] = useState('');
  const [withdrawAmount, setWithdrawAmount] = useState('');

  const handleStake = async () => {
    if (!stakeAmount || parseFloat(stakeAmount) <= 0) return;
    
    const amountNum = parseFloat(stakeAmount);
    const allowanceNum = parseFloat(allowance);
    
    // Check if approval is needed
    if (allowanceNum < amountNum) {
      await approve(stakeAmount);
      // Wait a bit for approval to complete
      setTimeout(() => refetchAll(), 2000);
    } else {
      await stake(stakeAmount);
      setTimeout(() => {
        refetchAll();
        setStakeAmount('');
      }, 2000);
    }
  };

  const handleWithdraw = async () => {
    if (!withdrawAmount || parseFloat(withdrawAmount) <= 0) return;
    await withdraw(withdrawAmount);
    setTimeout(() => {
      refetchAll();
      setWithdrawAmount('');
    }, 2000);
  };

  const handleClaim = async () => {
    await claimRewards();
    setTimeout(() => refetchAll(), 2000);
  };

  const needsApproval = parseFloat(stakeAmount || '0') > parseFloat(allowance);

  return (
    <Card className="w-full max-w-2xl">
      <CardHeader>
        <CardTitle className="text-2xl font-bold">Yield Farming Pool</CardTitle>
        <CardDescription>Stake tokens to earn rewards</CardDescription>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="stake" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="stake">Stake</TabsTrigger>
            <TabsTrigger value="withdraw">Withdraw</TabsTrigger>
          </TabsList>
          
          <TabsContent value="stake" className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="stake-amount">Amount to Stake</Label>
              <Input
                id="stake-amount"
                type="number"
                placeholder="0.0"
                value={stakeAmount}
                onChange={(e) => setStakeAmount(e.target.value)}
                disabled={!address}
              />
              <p className="text-sm text-muted-foreground">
                Available: {parseFloat(stakeTokenBalance).toFixed(4)} STAKE
              </p>
            </div>
            
            <Button 
              onClick={handleStake} 
              className="w-full"
              disabled={!address || !stakeAmount || parseFloat(stakeAmount) <= 0 || isApproving || isStaking}
            >
              {isApproving ? 'Approving...' : isStaking ? 'Staking...' : needsApproval ? 'Approve & Stake' : 'Stake'}
            </Button>
          </TabsContent>
          
          <TabsContent value="withdraw" className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="withdraw-amount">Amount to Withdraw</Label>
              <Input
                id="withdraw-amount"
                type="number"
                placeholder="0.0"
                value={withdrawAmount}
                onChange={(e) => setWithdrawAmount(e.target.value)}
                disabled={!address}
              />
              <p className="text-sm text-muted-foreground">
                Staked: {parseFloat(stakedAmount).toFixed(4)} STAKE
              </p>
            </div>
            
            <Button 
              onClick={handleWithdraw} 
              className="w-full"
              variant="outline"
              disabled={!address || !withdrawAmount || parseFloat(withdrawAmount) <= 0 || isWithdrawing}
            >
              {isWithdrawing ? 'Withdrawing...' : 'Withdraw'}
            </Button>
          </TabsContent>
        </Tabs>

        <div className="mt-6 p-4 bg-secondary rounded-lg space-y-3">
          <div className="flex justify-between items-center">
            <span className="text-sm font-medium">Your Staked Amount</span>
            <span className="text-lg font-bold">{parseFloat(stakedAmount).toFixed(4)} STAKE</span>
          </div>
          
          <div className="flex justify-between items-center">
            <span className="text-sm font-medium">Pending Rewards</span>
            <span className="text-lg font-bold text-accent">{parseFloat(pendingRewards).toFixed(4)} REWARD</span>
          </div>
          
          <Button 
            onClick={handleClaim} 
            className="w-full mt-2"
            variant="default"
            disabled={!address || parseFloat(pendingRewards) <= 0 || isClaiming}
          >
            {isClaiming ? 'Claiming...' : 'Claim Rewards'}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
