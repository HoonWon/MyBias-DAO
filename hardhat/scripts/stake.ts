import { ethers } from 'hardhat';
import { MyBiasBaseFund, Strategy } from '../typechain-types';
import { createdFund } from '../config.json';

const main = async () => {
  const [owner] = await ethers.getSigners();

  const fundAddress = createdFund[createdFund.length - 1].address;
  const fund = <MyBiasBaseFund>await ethers.getContractAt('MyBiasBaseFund', fundAddress, owner);
  const strategyAddress = await fund.strategies(0);
  const strategy = <Strategy>await ethers.getContractAt('Strategy', strategyAddress, owner);

  // stake lpToken
  console.info('stake lpToken...');
  await (await strategy.stakeLpToken(await strategy.getLpTokenBalance())).wait();
  console.info();
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
