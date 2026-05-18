import hre from "hardhat";

async function main() {
  
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

  // compute selector for acceptOwnership() using ethers when available
  let ACCEPT_OWNERSHIP_SELECTOR = ""; // fallback
  let grantAccess_SELECTOR = ""; // fallback
  let setItemPrice_SELECTOR = ""; // fallback
  let transferOwnership_SELECTOR = ""; // fallback
  try {
    const ethers = await import("ethers");
    const { utils } = ethers;
    ACCEPT_OWNERSHIP_SELECTOR = utils.id("acceptOwnership()").slice(0, 10);
    grantAccess_SELECTOR = utils.id("grantAccess(address)").slice(0, 10);
    setItemPrice_SELECTOR = utils.id("setItemPrice(uint256,uint256)").slice(0, 10);
    transferOwnership_SELECTOR = utils.id("transferOwnership(address)").slice(0, 10);
    const iface = new ethers.utils.Interface(['function setItemPrice(uint256 itemId, uint256 priceInTokens)']);
    const encodedData = iface.encodeFunctionData('setItemPrice', [1, 50n]);
    console.log("\nEncoded data for setItemPrice(1, 50):", encodedData);
    console.log("\nComputed selectors using ethers:");
    console.log("acceptOwnership() selector (computed via ethers):", ACCEPT_OWNERSHIP_SELECTOR);
    console.log("grantAccess(address) selector (computed via ethers):", grantAccess_SELECTOR);
    console.log("setItemPrice(uint256,uint256) selector (computed via ethers):", setItemPrice_SELECTOR);
    console.log("transferOwnership(address) selector (computed via ethers):", transferOwnership_SELECTOR);
    console.log("_data for setItemPrice(1, 50):", encodedData);
  } catch (e) {
    console.log("\nCould not compute selector via ethers, using fallback selector:", ACCEPT_OWNERSHIP_SELECTOR);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
