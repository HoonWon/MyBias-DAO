import { ethers } from 'hardhat';
import dotenv from 'dotenv';
import { MyBiasNFTFactoryAddress, MyBiasFundFactoryAddress } from '../config.json';
import { abi as MyBiasNFTFactoryABI } from '../artifacts/contracts/MyBiasNFTFactory.sol/MyBiasNFTFactory.json';
import { abi as MyBiasFundFactoryABI } from '../artifacts/contracts/MyBiasFundFactory.sol/MyBiasFundFactory.json';
import { abi as MyBiasBaseNFTABI } from '../artifacts/contracts/MyBiasBaseNFT.sol/MyBiasBaseNFT.json';
import { abi as MyBiasBaseFundABI } from '../artifacts/contracts/MyBiasBaseFund.sol/MyBiasBaseFund.json';
import { MyBiasBaseFund, MyBiasBaseNFT, MyBiasFundFactory, MyBiasNFTFactory } from '../typechain-types';
import { isEmpty } from 'lodash';
import { readFileSync, writeFileSync } from 'fs';

const main = async () => {
  dotenv.config();
  const { NAME, SYMBOL, WETH } = process.env;

  if (!NAME || !SYMBOL || !WETH) {
    throw new Error('invalid node env!');
  }

  const [deployer] = await ethers.getSigners();
  const myBiasNFTFactory = <MyBiasNFTFactory>(
    await ethers.getContractAt(MyBiasNFTFactoryABI, MyBiasNFTFactoryAddress, deployer)
  );
  const myBiasFundFactory = <MyBiasFundFactory>(
    await ethers.getContractAt(MyBiasFundFactoryABI, MyBiasFundFactoryAddress, deployer)
  );

  console.log(`Clone ${NAME} NFT...`);
  const { events: NFTEvents } = await (
    await myBiasNFTFactory.createNFT(deployer.address, NAME, SYMBOL, deployer.address)
  ).wait();

  const { args: NFTArgs } = NFTEvents?.find(({ event }) => event === 'MyBiasNFTCreated') || {};
  if (!NFTArgs || isEmpty(NFTArgs)) {
    throw new Error('NFT clone failed. There is no cloned NFT');
  }

  const [clonedNFTAddress] = NFTArgs;

  console.log("Cloned NFT's address:", clonedNFTAddress);
  console.log();

  console.log(`Clone ${NAME} Fund...`);
  const { events: fundEvents } = await (
    await myBiasFundFactory.createFund(deployer.address, NAME, WETH, deployer.address)
  ).wait();

  const { args: fundArgs } = fundEvents?.find(({ event }) => event === 'MyBiasFundCreated') || {};
  if (!fundArgs || isEmpty(fundArgs)) {
    throw new Error('Fund clone failed. There is no cloned Fund');
  }

  const [clonedFundAddress] = fundArgs;

  console.log("Cloned Fund's address:", clonedFundAddress);
  console.log();

  const clonedNFT = <MyBiasBaseNFT>await ethers.getContractAt(MyBiasBaseNFTABI, clonedNFTAddress);
  const NFTName = await clonedNFT.name();
  const NFTSymbol = await clonedNFT.symbol();

  const clonedFund = <MyBiasBaseFund>await ethers.getContractAt(MyBiasBaseFundABI, clonedFundAddress);
  const fundName = await clonedFund.name();

  const path = `${__dirname}/../config.json`;
  const data = readFileSync(path, 'utf8');
  const jsonData = JSON.parse(data);

  jsonData.clonedNFT = [
    ...(jsonData.clonedNFT || []),
    {
      address: clonedNFTAddress,
      name: NFTName,
      symbol: NFTSymbol,
    },
  ];

  jsonData.clonedFund = [
    ...(jsonData.clonedFund || []),
    {
      address: clonedFundAddress,
      name: fundName,
    },
  ];

  writeFileSync(path, JSON.stringify(jsonData));
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
