import { ethers } from 'hardhat';
import { BigNumber, utils, constants } from 'ethers';
import {
  MyBiasBaseFund,
  MyBiasBaseNFT,
  MyBiasBaseGovernanceToken,
  Strategy__factory,
  MyBiasGovernanceTokenFactory,
  MyBiasFundFactory,
  MyBiasNFTFactory,
} from '../typechain-types';
import { fundFactoryAddress, governanceTokenFactoryAddress, nftFactoryAddress } from '../config.json';
import { readFileSync, writeFileSync } from 'fs';

const main = async () => {
  const [owner] = await ethers.getSigners();

  const nftPrice = utils.parseEther('0.01');
  const target = 'Stacy';

  // createFanDao
  console.info('createFund...');
  const fundFactory = <MyBiasFundFactory>await ethers.getContractAt('MyBiasFundFactory', fundFactoryAddress, owner);
  await (await fundFactory.createFund()).wait();
  console.info();

  console.info('createGovernanceToken...');
  const governanceTokenFactory = <MyBiasGovernanceTokenFactory>(
    await ethers.getContractAt('MyBiasGovernanceTokenFactory', governanceTokenFactoryAddress, owner)
  );
  await (await governanceTokenFactory.createGovernanceToken()).wait();
  console.info();

  console.info('createNft...');
  const nftFactory = <MyBiasNFTFactory>await ethers.getContractAt('MyBiasNFTFactory', nftFactoryAddress, owner);
  await (await nftFactory.createNFT()).wait();
  console.info();

  const nftAddress = await nftFactory.latestCreatedNFT();
  const fundAddress = await fundFactory.latestCreatedFund();
  const governaceTokenAddress = await governanceTokenFactory.latestCreatedGovernanceToken();

  console.info('createInitialStrategy...');
  const strategyFactory = <Strategy__factory>await ethers.getContractFactory('Strategy');
  const strategy = await strategyFactory.deploy(owner.address, fundAddress);
  console.info();

  console.info('Init governanceToken...');
  await (await governanceTokenFactory.initGovernanceToken(owner.address, nftAddress, target)).wait();
  console.info();

  console.info('Init NFT...');
  const maxNum = 100;
  const maxBuyNum = 100;
  await (
    await nftFactory.initNFT(
      owner.address,
      target,
      governaceTokenAddress,
      fundAddress,
      owner.address,
      nftPrice,
      maxNum,
      maxBuyNum,
    )
  ).wait();
  console.info();

  console.info('Init fund...');
  const votingDelay = 1;
  const votingPeriod = 150;
  await (
    await fundFactory.initFund(
      governaceTokenAddress,
      owner.address,
      target,
      votingDelay,
      votingPeriod,
      0,
      strategy.address,
    )
  ).wait();
  console.info();

  const governanceToken = <MyBiasBaseGovernanceToken>(
    await ethers.getContractAt('MyBiasBaseGovernanceToken', governaceTokenAddress)
  );
  const nft = <MyBiasBaseNFT>await ethers.getContractAt('MyBiasBaseNFT', nftAddress);
  const fund = <MyBiasBaseFund>await ethers.getContractAt('MyBiasBaseFund', fundAddress);

  console.info('FUND_CONTRACT_ADDRESS: ', fund.address);
  console.info('GOVERNANCE_CONTRACT_ADDRESS: ', governanceToken.address);
  console.info('NFT_CONTRACT_ADDRESS: ', nft.address);

  const path = `${__dirname}/../config.json`;
  const data = readFileSync(path, 'utf8');
  const jsonData = JSON.parse(data);

  jsonData.createdFund = [
    ...(jsonData.createdFund || []),
    {
      address: fund.address,
      strategies: [strategy.address],
      target,
    },
  ];

  jsonData.createdGovernanceToken = [
    ...(jsonData.createdGovernanceToken || []),
    {
      address: governanceToken.address,
      target,
    },
  ];

  jsonData.createdNFT = [
    ...(jsonData.createdNFT || []),
    {
      address: nft.address,
      target,
    },
  ];

  writeFileSync(path, JSON.stringify(jsonData));
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
