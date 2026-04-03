import "dotenv/config";
import { defineConfig } from "hardhat/config";
import hardhatIgnitionViemPlugin from "@nomicfoundation/hardhat-ignition-viem";
import hardhatNodeTestRunnerPlugin from "@nomicfoundation/hardhat-node-test-runner";

const sepoliaRpcUrl = process.env.SEPOLIA_RPC_URL || "https://eth-sepolia.g.alchemy.com/v2/YOUR_PROJECT_ID";
const privateWalletKey = process.env.PRIVATE_KEY || "YOUR_WALLET_PRIVATE_KEY";
const privateEtherscanKey = process.env.ETHERSCAN_API_KEY || "YOUR_ETHERSCAN_API_KEY";

export default defineConfig({
  plugins: [hardhatIgnitionViemPlugin, hardhatNodeTestRunnerPlugin],
  solidity: {
    version: "0.8.28",
  },
  networks: {
    sepolia: {
      type: "http",
      chainType: "l1",
      url: sepoliaRpcUrl,
      accounts: [privateWalletKey],
    },
  },
  verify: {
    etherscan: {
      apiKey: privateEtherscanKey,
    },
  },
  paths: {
    sources: "./code/contracts",
    tests: "./code/test",
    ignition: "./deployment/ignition",
  },
});
