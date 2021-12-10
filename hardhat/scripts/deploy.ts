import { ethers } from 'hardhat';
import {
  MyBiasBaseFund__factory,
  MyBiasGovernanceTokenFactory__factory,
  MyBiasBaseGovernanceToken__factory,
  MyBiasBaseNFT__factory,
  MyBiasNFTFactory__factory,
  MyBiasFundFactory__factory,
} from '../typechain-types';
import { writeFileSync } from 'fs';

const main = async () => {
  const [owner] = await ethers.getSigners();

  // deploy
  console.info('Deploy baseGovernanceToken...');
  const baseGovernanceTokenFactory = <MyBiasBaseGovernanceToken__factory>(
    await ethers.getContractFactory('MyBiasBaseGovernanceToken', owner)
  );
  const baseGovernanceToken = await baseGovernanceTokenFactory.deploy();
  console.info();

  console.info('Deploy baseNFT...');
  const baseNftFactory = <MyBiasBaseNFT__factory>await ethers.getContractFactory('MyBiasBaseNFT', owner);
  const baseNft = await baseNftFactory.deploy();
  console.info();

  console.info('Deploy baseFund...');
  const baseFundFactory = <MyBiasBaseFund__factory>await ethers.getContractFactory('MyBiasBaseFund', owner);
  const baseFund = await baseFundFactory.deploy();
  console.info();

  console.info('Deploy governanceTokenFactory...');
  const governanceTokenFactoryFactory = <MyBiasGovernanceTokenFactory__factory>(
    await ethers.getContractFactory('MyBiasGovernanceTokenFactory', owner)
  );
  const governanceTokenFactory = await governanceTokenFactoryFactory.deploy(owner.address, baseGovernanceToken.address);
  console.info();

  console.info('Deploy NFTFactory...');
  const nftFactoryFactory = <MyBiasNFTFactory__factory>await ethers.getContractFactory('MyBiasNFTFactory', owner);
  const nftFactory = await nftFactoryFactory.deploy(owner.address, baseNft.address);
  console.info();

  console.info('Deploy fundFactory...');
  const fundFactoryFactory = <MyBiasFundFactory__factory>await ethers.getContractFactory('MyBiasFundFactory', owner);
  const fundFactory = await fundFactoryFactory.deploy(owner.address, baseFund.address);
  console.info();

  const path = `${__dirname}/../config.json`;
  const data = {
    baseFund: baseFund.address,
    baseGovernanceToken: baseGovernanceToken.address,
    baseNft: baseNft.address,
    fundFactoryAddress: fundFactory.address,
    governanceTokenFactoryAddress: governanceTokenFactory.address,
    nftFactoryAddress: nftFactory.address,
  };

  writeFileSync(path, JSON.stringify(data));
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
