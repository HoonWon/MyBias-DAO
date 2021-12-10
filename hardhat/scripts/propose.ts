import { ethers } from 'hardhat';
import { BigNumber, utils, constants } from 'ethers';
import { MyBiasBaseFund } from '../typechain-types';
import { createdFund } from '../config.json';
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

const main = async () => {
  const fundAddress = createdFund[createdFund.length - 1].address;

  const fund = <MyBiasBaseFund>await ethers.getContractAt('MyBiasBaseFund', fundAddress);
  const maticBalance = utils.parseEther('0.001');

  console.info('propose send matic...');
  const callData = fund.interface.encodeFunctionData('sendMatic', [
    '0x10B9bB7Bc8D9278C14A5c971CA4B2130257e5fED',
    maticBalance,
  ]);
  const description = `#${Math.random()}: sendMatic`;
  const descriptionHash = ethers.utils.id(description);
  const proposalId = await fund.hashProposal([fund.address], [0], [callData], descriptionHash);
  await (await fund.propose([fund.address], [0], [callData], description)).wait();

  const path = `${__dirname}/../config.json`;
  const data = readFileSync(path, 'utf8');
  const jsonData = JSON.parse(data);

  jsonData.proposal = [...(jsonData.proposal || []), { id: proposalId.toHexString(), description }];

  writeFileSync(path, JSON.stringify(jsonData));
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
