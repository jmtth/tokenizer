import { defineConfig } from "hardhat/config";
import hardhatIgnitionViemPlugin from "@nomicfoundation/hardhat-ignition-viem";
import hardhatNodeTestRunnerPlugin from "@nomicfoundation/hardhat-node-test-runner";

export default defineConfig({
  plugins: [hardhatIgnitionViemPlugin, hardhatNodeTestRunnerPlugin],
  solidity: {
    version: "0.8.28",
  },
});
