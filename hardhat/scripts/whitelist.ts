import { ethers } from 'hardhat';

const main = async () => {
  const [owner] = await ethers.getSigners();

  console.info('enalbe public sale');
  const sig = await owner.signMessage(Buffer.from(owner.address.slice(2), 'hex'));
  console.info('Sig: ', sig);
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
