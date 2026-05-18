import hre from "hardhat";

async function main() {
  // Retrieve accounts from the JSON-RPC provider (works for hardhat node)
  let accounts: string[] = [];
  try {
    // @ts-ignore - provider.request exists on the Hardhat network provider
    accounts = (await hre.network.provider.request({ method: "eth_accounts", params: [] })) as string[];
  } catch (e) {
    console.error("Could not query provider eth_accounts:", e instanceof Error ? e.message : e);
  }

  console.log("RPC accounts:");
  if (accounts && accounts.length) {
    accounts.forEach((a, i) => console.log(`${i}: ${a}`));
  } else {
    console.log("(no accounts returned by provider)");
  }
  // compute selector for acceptOwnership() using ethers when available
  let ACCEPT_OWNERSHIP_SELECTOR = "0x79ba5097"; // fallback
  try {
    const ethers = await import("ethers");
    const { utils } = ethers;
    ACCEPT_OWNERSHIP_SELECTOR = utils.id("acceptOwnership()").slice(0, 10);
    console.log("\nacceptOwnership() selector (computed via ethers):", ACCEPT_OWNERSHIP_SELECTOR);
  } catch (e) {
    console.log("\nCould not compute selector via ethers, using fallback selector:", ACCEPT_OWNERSHIP_SELECTOR);
  }
    // If PRIVATE_KEYS are set in the environment, derive and print their corresponding addresses
  const keysFromEnv = process.env.PRIVATE_KEYS ? process.env.PRIVATE_KEYS.split(",").map((k) => k.trim()).filter(Boolean) : [];
  if (keysFromEnv.length) {
    console.log("\nConfigured PRIVATE_KEYS addresses:");
    for (const k of keysFromEnv) {
      try {
        const { Wallet } = await import("ethers");
        const w = new Wallet(k.startsWith("0x") ? k : `0x${k}`);
        console.log(w.address);
      } catch (e) {
        console.log("One of the PRIVATE_KEYS is set, but 'ethers' is not installed or failed to load.");
        console.log("Install ethers (`npm install ethers`) to derive the addresses automatically.");
        break;
      }
    }
  } else {
    console.log("\nNo PRIVATE_KEYS found in environment.");
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
