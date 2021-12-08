import { ethers } from 'hardhat';
import { BigNumber, utils, constants } from 'ethers';
import {
  MyBiasBaseFund,
  MyBiasBaseFund__factory,
  MyBiasBaseNFT,
  MyBiasGovernanceTokenFactory__factory,
  MyBiasBaseGovernanceToken__factory,
  MyBiasBaseGovernanceToken,
  MyBiasBaseNFT__factory,
  MyBiasNFTFactory__factory,
  MyBiasFundFactory__factory,
  Strategy__factory,
  MockERC20Token,
} from '../typechain-types';

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
  const [owner, alice, bob, carol, dave, dummy] = await ethers.getSigners();

  const nftPrice = utils.parseEther('5000');
  const deadline = (await latestTime()).add(duration.years(20));

  // deploy and clone
  console.info('Deploy and Clone');
  console.info();
  const baseGovernanceTokenFactory = <MyBiasBaseGovernanceToken__factory>(
    await ethers.getContractFactory('MyBiasBaseGovernanceToken')
  );
  const baseGovernanceToken = await baseGovernanceTokenFactory.deploy();

  const baseNftFactory = <MyBiasBaseNFT__factory>await ethers.getContractFactory('MyBiasBaseNFT');
  const baseNft = await baseNftFactory.deploy();

  const baseFundFactory = <MyBiasBaseFund__factory>await ethers.getContractFactory('MyBiasBaseFund');
  const baseFund = await baseFundFactory.deploy();

  const governanceTokenFactoryFactory = <MyBiasGovernanceTokenFactory__factory>(
    await ethers.getContractFactory('MyBiasGovernanceTokenFactory')
  );
  const governaceTokenFactory = await governanceTokenFactoryFactory.deploy(owner.address, baseGovernanceToken.address);
  await governaceTokenFactory.createGovernanceToken();

  const nftFactoryFactory = <MyBiasNFTFactory__factory>await ethers.getContractFactory('MyBiasNFTFactory');
  const nftFactory = await nftFactoryFactory.deploy(owner.address, baseNft.address);
  await nftFactory.createNFT();

  const fundFactoryFactory = <MyBiasFundFactory__factory>await ethers.getContractFactory('MyBiasFundFactory');
  const fundFactory = await fundFactoryFactory.deploy(owner.address, baseFund.address);
  await fundFactory.createFund();

  const governaceToken1Address = await governaceTokenFactory.latestCreatedGovernanceToken();
  const nft1Address = await nftFactory.latestCreatedNFT();
  const fund1Address = await fundFactory.latestCreatedFund();

  const strategyFactory = <Strategy__factory>await ethers.getContractFactory('Strategy');
  const strategy = await strategyFactory.deploy(owner.address, fund1Address);

  await governaceTokenFactory.initGovernanceToken(owner.address, nft1Address, 'stacy');
  await nftFactory.initNFT(
    owner.address,
    'stacy',
    governaceToken1Address,
    fund1Address,
    owner.address,
    nftPrice,
    100,
    10,
  );
  await fundFactory.initFund(governaceToken1Address, owner.address, 'stacy', 1, 20, 0, strategy.address);

  const governanceToken1 = <MyBiasBaseGovernanceToken>(
    await ethers.getContractAt('MyBiasBaseGovernanceToken', governaceToken1Address)
  );
  const nft1 = <MyBiasBaseNFT>await ethers.getContractAt('MyBiasBaseNFT', nft1Address);
  const fund1 = <MyBiasBaseFund>await ethers.getContractAt('MyBiasBaseFund', fund1Address);

  // nft preSale
  console.info('NFT preSale');
  console.info();
  await nft1.enablePreSale();

  // // whiteist alice, bob
  const aliceSig = await owner.signMessage(Buffer.from(alice.address.slice(2), 'hex'));
  const bobSig = await owner.signMessage(Buffer.from(bob.address.slice(2), 'hex'));

  // // preSale
  await nft1.connect(alice).preSale(aliceSig, 10, { value: nftPrice.mul(10) });
  await nft1.connect(bob).preSale(bobSig, 5, { value: nftPrice.mul(5) });

  await nft1.disablePreSale();

  // nft publicSale
  console.info('NFT publicSale');
  console.info();
  await nft1.enablePublicSale();

  // // public sale
  await nft1.connect(alice).publicSale(10, { value: nftPrice.mul(10) });
  await nft1.connect(bob).publicSale(10, { value: nftPrice.mul(10) });
  await nft1.connect(carol).publicSale(10, { value: nftPrice.mul(10) });
  await nft1.connect(dave).publicSale(10, { value: nftPrice.mul(10) });

  await nft1.disablePublicSale();

  // kill sale
  console.info('Kill sale');
  console.info();
  await nft1.killSale();

  // NFT matic balance
  console.info('NFT contract Matic balance: ', utils.formatEther(await ethers.provider.getBalance(nft1.address)));
  console.info();

  // sendMaticToFund
  console.info('sendMaticToFund');
  console.info();
  await nft1.sendMaticToFund();

  // NFT and Fund matic balance
  console.info('NFT contract Matic balance: ', utils.formatEther(await ethers.provider.getBalance(nft1.address)));
  console.info('Fund contract Matic balance: ', utils.formatEther(await ethers.provider.getBalance(fund1.address)));
  console.info();

  // send Matic To Initial Startegy
  console.info('send Matic to initial strategy');
  await fund1.sendMaticToStrategy(0, await ethers.provider.getBalance(fund1.address));
  console.info(
    "Strategy contract's Matic balance: ",
    utils.formatEther(await ethers.provider.getBalance(strategy.address)),
  );
  console.info();

  // swap matic to usdc ans usdt
  console.info('swap matic to usdc and usdt');
  let maticBalance = await strategy.getMaticBalance();
  await strategy.swapMaticToUsdc(maticBalance.div(2), 0, deadline);
  maticBalance = await strategy.getMaticBalance();
  await strategy.swapMaticToUsdt(maticBalance, 0, deadline);
  console.info("Strategy contract's USDC balance: ", utils.formatUnits(await strategy.getUsdcBalance(), 6));
  console.info("Strategy contract's USDT balance: ", utils.formatUnits(await strategy.getUsdtBalance(), 6));
  console.info();

  // add liquidity
  console.info('add liquidity(quickswap) to usdc-usdt pool');
  const USDC_ADDRESS = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';
  const USDT_ADDRESS = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';
  const usdcBalance = await strategy.getUsdcBalance();
  const usdtBalance = await strategy.getUsdtBalance();
  await strategy.addLiquidity(
    USDC_ADDRESS,
    USDT_ADDRESS,
    usdcBalance,
    usdtBalance,
    usdcBalance.mul(95).div(100),
    usdtBalance.mul(95).div(100),
    deadline,
  );
  console.info("Strategy contract's USDC balance: ", utils.formatUnits(await strategy.getUsdcBalance(), 6));
  console.info("Strategy contract's USDT balance: ", utils.formatUnits(await strategy.getUsdtBalance(), 6));
  console.info('lpToken balance: ', utils.formatUnits(await strategy.getLpTokenBalance(), 6));
  console.info();

  // stake lpToken
  console.info('stake lpToken');
  await strategy.stakeLpToken(await strategy.getLpTokenBalance());
  console.info();

  // increase time 1 days
  console.info('increase time 1 days');
  await increaseTime(duration.days(1));
  console.info();

  // claim dQuick
  console.info('claim dQuick');
  await strategy.claimDQUICK();
  console.info('dQuick balance: ', utils.formatEther(await strategy.getDQUICKBalance()));
  console.info();

  // withdraw all dQuick
  console.info('withdraw all dQuick');
  await strategy.withdrawAllDQUICK();
  console.info('Quick balance: ', utils.formatEther(await strategy.getQuickBalance()));
  console.info();

  // swap quick to usdc and usdt
  console.info('swap quick to usdc and usdt');
  const QUICK_ADDRESS = '0x831753DD7087CaC61aB5644b308642cc1c33Dc13';
  const quickBalance = await strategy.getQuickBalance();
  await strategy.swapExactTokensForTokens(quickBalance.div(2), 0, [QUICK_ADDRESS, USDC_ADDRESS], deadline);
  await strategy.swapExactTokensForTokens(quickBalance.div(2), 0, [QUICK_ADDRESS, USDT_ADDRESS], deadline);
  console.info("Strategy contract's USDC balance: ", utils.formatUnits(await strategy.getUsdcBalance(), 6));
  console.info("Strategy contract's USDT balance: ", utils.formatUnits(await strategy.getUsdtBalance(), 6));
  console.info();

  // propose transfer 100 usdc and 100 usdt to Dave
  console.info('Propose transfer 100 usdc and 100 usdt to Dave');
  const USDC = <MockERC20Token>await ethers.getContractAt('MockERC20Token', USDC_ADDRESS);
  const USDT = <MockERC20Token>await ethers.getContractAt('MockERC20Token', USDT_ADDRESS);
  const callData1 = USDC.interface.encodeFunctionData('transfer', [dave.address, utils.parseUnits('100.0', 6)]);
  const callData2 = USDT.interface.encodeFunctionData('transfer', [dave.address, utils.parseUnits('100.0', 6)]);
  await governanceToken1.connect(alice).delegate(alice.address);
  await governanceToken1.connect(bob).delegate(bob.address);
  await governanceToken1.connect(carol).delegate(carol.address);
  const descriptionHash1 = ethers.utils.id('#1: send usdc and usdt');
  const proposalId1 = await fund1.hashProposal(
    [USDC_ADDRESS, USDT_ADDRESS],
    [0, 0],
    [callData1, callData2],
    descriptionHash1,
  );
  await fund1.propose([USDC_ADDRESS, USDT_ADDRESS], [0, 0], [callData1, callData2], '#1: send usdc and usdt');
  await mine(2);
  console.info();

  // vote - alice: agree, bob: agree,  carol: disagree
  console.info('vote - alice: agree, bob: agree,  carol: disagree');
  await fund1.connect(alice).castVote(proposalId1, 1);
  await fund1.connect(bob).castVote(proposalId1, 1);
  await fund1.connect(carol).castVote(proposalId1, 0);
  await mine(20);
  console.info();

  // unstake lp token
  console.info('unstake lp token');
  await strategy.unstakeLpToken();
  console.info();

  // remove liquidity
  console.info('remove liquidity');
  const lpTokenBalance = await strategy.getLpTokenBalance();
  await strategy.removeLiquidity(USDC_ADDRESS, USDT_ADDRESS, lpTokenBalance, 0, 0, deadline);
  console.info();

  // send usdc and usdt to fund contract from starategy
  console.info('send usdc and usdt to fund contract from starategy');
  await strategy.withdrawUSDC(await strategy.getUsdcBalance());
  await strategy.withdrawUSDT(await strategy.getUsdtBalance());
  console.info();

  // execute propsal
  console.info('exectue proposal');
  await fund1.execute([USDC_ADDRESS, USDT_ADDRESS], [0, 0], [callData1, callData2], descriptionHash1);
  console.info();

  console.info("dave's USDC balance: ", utils.formatUnits(await USDC.balanceOf(dave.address), 6));
  console.info("dave's USDT balance: ", utils.formatUnits(await USDT.balanceOf(dave.address), 6));
  console.info();

  // propose strategy add
  console.info('propse strategy add');
  const callData3 = fund1.interface.encodeFunctionData('addStrategy', [dummy.address]);
  const descriptionHash2 = ethers.utils.id('#2: add strategy');
  const proposalId2 = await fund1.hashProposal([fund1.address], [0], [callData3], descriptionHash2);
  await fund1.propose([fund1.address], [0], [callData3], '#2: add strategy');
  await mine(2);
  console.info();

  // vote - alice: agree, bob: agree,  carol: disagree
  console.info('vote - alice: agree, bob: agree,  carol: disagree');
  await fund1.connect(alice).castVote(proposalId2, 1);
  await fund1.connect(bob).castVote(proposalId2, 1);
  await fund1.connect(carol).castVote(proposalId2, 0);
  await mine(20);
  console.info();

  // execute propsal
  console.info('exectue proposal');
  await fund1.execute([fund1.address], [0], [callData3], descriptionHash2);
  console.info('strategies[1]: ', await fund1.strategies(1));
  console.info();
};

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
