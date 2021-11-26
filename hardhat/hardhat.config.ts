import { HardhatUserConfig } from 'hardhat/config';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import 'solidity-coverage';
import 'hardhat-spdx-license-identifier';
import '@typechain/ethers-v5';

const config: HardhatUserConfig = {
  solidity: {
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    version: '0.8.0',
  },
  networks: {
    mumbai: {
      url: 'https://polygon-mumbai.g.alchemy.com/v2/ADSruID4vzTM1QYhd4JKZBXwNp_XoJR-',
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    hardhat: {
      gas: 10000000,
      accounts: {
        accountsBalance: '1000000000000000000000000',
      },
      allowUnlimitedContractSize: true,
    },
    coverage: {
      url: 'http://localhost:8555',
    },
  },
};

export default config;
