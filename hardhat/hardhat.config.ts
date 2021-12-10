import { HardhatUserConfig } from 'hardhat/config';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import 'solidity-coverage';
import 'hardhat-spdx-license-identifier';
import '@typechain/ethers-v5';
import dotenv from 'dotenv';

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    version: '0.8.2',
  },
  networks: {
    polygon: {
      url: 'https://polygon-mainnet.infura.io/v3/e247382e38d74a9d8ab06a58614dd170',
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    polygonTest: {
      url: 'https://polygon-mumbai.g.alchemy.com/v2/ADSruID4vzTM1QYhd4JKZBXwNp_XoJR-',
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    // hardhat: {
    //   forking: {
    //     url: 'https://polygon-mainnet.g.alchemy.com/v2/tGorwxRYuv_hlVCzvejeeGy7dfC8uCCQ',
    //   },
    //   gas: 10000000,
    //   accounts: {
    //     accountsBalance: '1000000000000000000000000',
    //   },
    //   allowUnlimitedContractSize: true,
    // },
    coverage: {
      url: 'http://localhost:8555',
    },
  },
};

export default config;
