import { ethers } from 'hardhat';
import { BigNumber, utils } from 'ethers';
import { MyBiasBaseFund, Strategy } from '../typechain-types';
import { createdFund } from '../config.json';

const duration = {
  seconds: function (val: any) {
    return BigNumber.from(val);
  },
  minutes: function (val: any) {
    return BigNumber.from(val).mul(this.seconds('60'));
  },
  hours: function (val: any) {
    return BigNumber.from(val).mul(this.minutes('60'));
  },
  days: function (val: any) {
    return BigNumber.from(val).mul(this.hours('24'));
  },
  weeks: function (val: any) {
    return BigNumber.from(val).mul(this.days('7'));
  },
  years: function (val: any) {
    return BigNumber.from(val).mul(this.days('365'));
  },
};

async function latestTime() {
  const block = await ethers.provider.getBlock('latest');
  return BigNumber.from(block.timestamp);
}

async function mine(num: number) {
  for (let i = 0; i < num; i += 1) {
    await ethers.provider.send('evm_mine', []);
  }
}

const main = async () => {
  const [owner] = await ethers.getSigners();

  const deadline = (await latestTime()).add(duration.minutes(20));

  const fundAddress = createdFund[createdFund.length - 1].address;
  const fund = <MyBiasBaseFund>await ethers.getContractAt('MyBiasBaseFund', fundAddress, owner);
  const strategyAddress = await fund.strategies(0);
  const strategy = <Strategy>await ethers.getContractAt('Strategy', strategyAddress, owner);

  // add liquidity
  console.info('add liquidity(quickswap) to usdc-usdt pool..');
  // // Polygon Mainnet
  const USDC_ADDRESS = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';
  const USDT_ADDRESS = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';

  const usdcBalance = (await strategy.getUsdcBalance()).toNumber();
  const usdtBalance = (await strategy.getUsdtBalance()).toNumber();
  const amount = Math.min(usdcBalance, usdtBalance);
  await (await strategy.addLiquidity(USDC_ADDRESS, USDT_ADDRESS, amount, amount, 0, 0, deadline)).wait();
  console.info("Strategy contract's USDC balance: ", utils.formatUnits(await strategy.getUsdcBalance(), 6));
  console.info("Strategy contract's USDT balance: ", utils.formatUnits(await strategy.getUsdtBalance(), 6));
  console.info('lpToken balance: ', utils.formatUnits(await strategy.getLpTokenBalance(), 18));
  console.info();
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
