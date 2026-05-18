import "dotenv/config";
import { defineConfig } from "hardhat/config";
import hardhatIgnitionViemPlugin from "@nomicfoundation/hardhat-ignition-viem";
import hardhatNodeTestRunnerPlugin from "@nomicfoundation/hardhat-node-test-runner";

const sepoliaRpcUrl = process.env.SEPOLIA_RPC_URL || "https://eth-sepolia.g.alchemy.com/v2/YOUR_PROJECT_ID";
const privateEtherscanKey = process.env.ETHERSCAN_API_KEY || "YOUR_ETHERSCAN_API_KEY";

// Support either a single PRIVATE_KEY or multiple PRIVATE_KEYS (comma-separated) in the .env
const privateKeysFromEnv = process.env.PRIVATE_KEYS
  ? process.env.PRIVATE_KEYS.split(",").map((k) => k.trim()).filter(Boolean)
  : process.env.PRIVATE_KEY
  ? [process.env.PRIVATE_KEY.trim()]
  : [];

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
      accounts: privateKeysFromEnv.length ? privateKeysFromEnv : undefined,
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
