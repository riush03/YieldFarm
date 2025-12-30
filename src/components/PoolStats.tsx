import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { useStakingContract } from '../hooks/useStakingContract';
import { useAccount } from 'wagmi';

export function PoolStats() {
  const { address } = useAccount();
  const { totalStaked, rewardRate, stakeTokenBalance, rewardTokenBalance } = useStakingContract(address);

  const stats = [
    {
      title: 'Total Value Locked',
      value: parseFloat(totalStaked).toFixed(2),
      unit: 'STAKE',
      description: 'Total tokens staked in pool',
    },
    {
      title: 'Reward Rate',
      value: parseFloat(rewardRate).toFixed(6),
      unit: 'REWARD/sec',
      description: 'Rewards distributed per second',
    },
    {
      title: 'Your STAKE Balance',
      value: parseFloat(stakeTokenBalance).toFixed(4),
      unit: 'STAKE',
      description: 'Available to stake',
    },
    {
      title: 'Your REWARD Balance',
      value: parseFloat(rewardTokenBalance).toFixed(4),
      unit: 'REWARD',
      description: 'Claimed rewards',
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 w-full">
      {stats.map((stat, index) => (
        <Card key={index}>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {stat.title}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {stat.value}
              <span className="text-sm font-normal text-muted-foreground ml-1">
                {stat.unit}
              </span>
            </div>
            <p className="text-xs text-muted-foreground mt-1">{stat.description}</p>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
