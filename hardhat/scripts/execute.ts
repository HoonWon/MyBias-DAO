import { ethers } from 'hardhat';
import { BigNumber, utils, constants } from 'ethers';
import { MyBiasBaseFund } from '../typechain-types';
import { createdFund, proposal } from '../config.json';
import { readFileSync, writeFileSync } from 'fs';

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

async function increaseTime(duration: BigNumber) {
  await ethers.provider.send('evm_increaseTime', [duration.toNumber()]);
  await ethers.provider.send('evm_mine', []);
}

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

  const fundAddress = createdFund[createdFund.length - 1].address;

  const fund = <MyBiasBaseFund>await ethers.getContractAt('MyBiasBaseFund', fundAddress);
  const { description } = proposal[proposal.length - 1];
  const maticBalance = utils.parseEther('0.001');

  console.info('execute...');
  const callData = fund.interface.encodeFunctionData('sendMatic', [owner.address, maticBalance]);
  const descriptionHash = ethers.utils.id(description);
  await (await fund.execute([fund.address], [0], [callData], descriptionHash)).wait();
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
