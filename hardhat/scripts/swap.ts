import { ethers } from 'hardhat';
import { BigNumber, utils, constants } from 'ethers';
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

const main = async () => {
  const [owner] = await ethers.getSigners();

  const deadline = (await latestTime()).add(duration.minutes(20));

  const fundAddress = createdFund[createdFund.length - 1].address;
  const fund = <MyBiasBaseFund>await ethers.getContractAt('MyBiasBaseFund', fundAddress, owner);
  const strategyAddress = await fund.strategies(0);
  const strategy = <Strategy>await ethers.getContractAt('Strategy', strategyAddress, owner);

  // swap matic to usdc ans usdt
  console.info('swap matic to usdc and usdt...');
  let maticBalance = await strategy.getMaticBalance();
  await (await strategy.swapMaticToUsdc(maticBalance.div(2), 0, deadline)).wait();
  maticBalance = await strategy.getMaticBalance();
  await (await strategy.swapMaticToUsdt(maticBalance, 0, deadline)).wait();
  console.info("Strategy contract's USDC balance: ", utils.formatUnits(await strategy.getUsdcBalance(), 6));
  console.info("Strategy contract's USDT balance: ", utils.formatUnits(await strategy.getUsdtBalance(), 6));
  console.info();
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
