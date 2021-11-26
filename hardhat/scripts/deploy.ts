import { ethers } from 'hardhat';
import { MyBiasSTACYNFT__factory } from '../typechain-types';

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  const MyBiasSTACYNFTFactory = <MyBiasSTACYNFT__factory>await ethers.getContractFactory('MyBiasSTACYNFT');
  const MyBiasSTACYNFT = await MyBiasSTACYNFTFactory.deploy(deployer.address);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
