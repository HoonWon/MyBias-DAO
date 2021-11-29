import { ethers } from 'hardhat';
import {
  MyBiasBaseFund__factory,
  MyBiasBaseNFT__factory,
  MyBiasFundFactory__factory,
  MyBiasNFTFactory__factory,
} from '../typechain-types';
import { writeFileSync } from 'fs';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deployer account:', deployer.address);
  console.log('Account balance:', (await deployer.getBalance()).toString());
  console.log();

  console.log('Deploying MyBiasBaseNFT...');
  const MyBiasBaseNFTFactory = <MyBiasBaseNFT__factory>await ethers.getContractFactory('MyBiasBaseNFT');
  const MyBiasBaseNFT = await MyBiasBaseNFTFactory.deploy();
  console.log("Deployed MyBiasBaseNFT's address:", MyBiasBaseNFT.address);
  console.log();

  console.log('Deploying MyBiasBaseFund...');
  const MyBiasBaseFundFactory = <MyBiasBaseFund__factory>await ethers.getContractFactory('MyBiasBaseFund');
  const MyBiasBaseFund = await MyBiasBaseFundFactory.deploy();
  console.log("Deployed MyBiasBaseFund's address:", MyBiasBaseFund.address);
  console.log();

  console.log('Deploying MyBiasNFTFactory...');
  const MyBiasNFTFactoryFactory = <MyBiasNFTFactory__factory>await ethers.getContractFactory('MyBiasNFTFactory');
  const MyBiasNFTFactory = await MyBiasNFTFactoryFactory.deploy(deployer.address, MyBiasBaseNFT.address);
  console.log("Deployed MyBiasNFTFactory's address:", MyBiasNFTFactory.address);
  console.log();

  console.log('Deploying MyBiasFundFactory...');
  const MyBiasFundFactoryFactory = <MyBiasFundFactory__factory>await ethers.getContractFactory('MyBiasFundFactory');
  const MyBiasFundFactory = await MyBiasFundFactoryFactory.deploy(deployer.address, MyBiasBaseFund.address);
  console.log("Deployed MyBiasFundFactory's address:", MyBiasFundFactory.address);
  console.log();

  const config = {
    deployerAddress: deployer.address,
    MyBiasBaseNFTAddress: MyBiasBaseNFT.address,
    MyBiasBaseFundAddress: MyBiasBaseFund.address,
    MyBiasNFTFactoryAddress: MyBiasNFTFactory.address,
    MyBiasFundFactoryAddress: MyBiasFundFactory.address,
  };

  writeFileSync(`${__dirname}/../config.json`, JSON.stringify(config));
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
