import { readFile } from "node:fs/promises";
import { network } from "hardhat";

(async () => {
  try {
    const { viem } = await network.connect();
    const publicClient = await viem.getPublicClient();

    // Resolve a readContract function compatible with the runtime.
    // Try publicClient.readContract -> viem.readContract -> dynamic import fallback.
    let readContract = publicClient.readContract || viem.readContract;
    if (!readContract) {
      const mod = await import("viem");
      readContract = mod.readContract;
    }

    const multisigAddress = process.env.MULTISIG_ADDRESS || "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // TODO: update with actual multisig address
    const shopAddress = process.env.SHOP_ADDRESS || "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // TODO: update with actual shop address
    const maxItemId = process.env.MAX_ITEM_ID ? Number(process.env.MAX_ITEM_ID) : 20;

    const deploymentArtifactBase = new URL(
      "../../deployment/ignition/deployments/chain-11155111/artifacts/",
      import.meta.url,
    );

    async function loadAbi(artifactFileName, fallbackAbi) {
      try {
        const artifactUrl = new URL(artifactFileName, deploymentArtifactBase);
        const rawArtifact = await readFile(artifactUrl, "utf8");
        const artifact = JSON.parse(rawArtifact);
        return artifact.abi || fallbackAbi;
      } catch {
        return fallbackAbi;
      }
    }

    const multisigAbi = await loadAbi("Goodies42BonusModule#Goodies42Management.json", [
      { name: "getTransactionCount", type: "function", stateMutability: "view", outputs: [{ type: "uint256" }] },
      { name: "getTransaction", type: "function", stateMutability: "view", inputs: [{ type: "uint256" }], outputs: [
        { type: "address" }, { type: "uint256" }, { type: "bytes" }, { type: "bool" }, { type: "uint256" }
      ] },
    ]);

    const shopAbi = await loadAbi("Goodies42CoreModule#Goodies42Shop.json", [
      { name: "itemPrice", type: "function", stateMutability: "view", inputs: [{ type: "uint256" }], outputs: [{ type: "uint256" }] }
    ]);

    console.log("\n--- Items and prices ---\n");
    for (let i = 0; i <= maxItemId; i++) {
      try {
        const price = await readContract({
          address: shopAddress,
          abi: shopAbi,
          functionName: "itemPrice",
          args: [BigInt(i)],
          client: publicClient,
        });
        if (price && price > 0n) {
          const human = Number(price) / 10 ** 18;
          console.log(`item ${i}: ${price} (raw wei) = ${human} tokens`);
        }
      } catch (e) {
        // ignore missing entries or errors for specific indices
      }
    }

    console.log("\n--- Pending multisig transactions ---\n");
    const count = await readContract({ address: multisigAddress, abi: multisigAbi, functionName: "getTransactionCount", client: publicClient });
    const total = Number(count);
    if (total === 0) {
      console.log("No transactions found.");
      return;
    }
    let pending = 0;
    for (let i = 0; i < total; i++) {
      const t = await readContract({ address: multisigAddress, abi: multisigAbi, functionName: "getTransaction", args: [BigInt(i)], client: publicClient });
      // t: [to, value, data, executed, numSignatures]
      const to = t[0];
      const value = t[1];
      const data = t[2];
      const executed = t[3];
      const numSignatures = t[4];
      if (!executed) {
        pending += 1;
        const selector = (data && data.length >= 10) ? data.slice(0, 10) : data;
        console.log(`txIndex=${i} to=${to} value=${value} signatures=${numSignatures} selector=${selector}`);
      }
    }
    if (pending === 0) console.log("No pending transactions.");
  } catch (err) {
    console.error(err);
    process.exitCode = 1;
  }
})();
