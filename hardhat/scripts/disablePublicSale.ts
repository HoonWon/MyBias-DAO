import { ethers } from 'hardhat';
import { MyBiasBaseNFT } from '../typechain-types';
import { createdNFT } from '../config.json';

const main = async () => {
  const [owner] = await ethers.getSigners();

  const nftAddress = createdNFT[createdNFT.length - 1].address;

  console.info('disable public sale');
  const nft = <MyBiasBaseNFT>await ethers.getContractAt('MyBiasBaseNFT', nftAddress, owner);
  await (await nft.disablePublicSale()).wait();
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
