import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "solidity-coverage";
import "hardhat-spdx-license-identifier";
import "@typechain/ethers-v5";

const config: HardhatUserConfig = {
  solidity: "0.8.0",
  networks: {
    hardhat: {
      gas: 10000000,
      accounts: {
        accountsBalance: "1000000000000000000000000",
      },
      allowUnlimitedContractSize: true,
    },
    coverage: {
      url: "http://localhost:8555",
    },
  },
};

export default config;
