import { network } from "hardhat";

const DECIMALS = 10n ** 18n;

function formatWhole(amount) {
  return (amount / DECIMALS).toString();
}

async function main() {
  const { viem } = await network.connect();

  const [staff, student] = await viem.getWalletClients();
  console.log("--- Initialisation de la simulation 42 ---");
  console.log("Staff (Admin):", staff.account.address);
  console.log("Étudiant:", student.account.address);

  const goodiesToken = await viem.deployContract("Goodies42");
  const tokenAddress = goodiesToken.address;
  console.log("\n[1] Token GOODIES42 déployé à:", tokenAddress);

  const goodies42Shop = await viem.deployContract("Goodies42Shop", [tokenAddress]);
  const shopAddress = goodies42Shop.address;
  console.log("[2] Shop déployé à:", shopAddress);

  console.log("\n--- Étape 1 : Fin de Piscine ---");
  await goodiesToken.write.mint([student.account.address, 100n], {
    account: staff.account,
  });
  const balanceAfterPiscine = await goodiesToken.read.balanceOf([student.account.address]);
  console.log("Staff: 'Bravo, voici 100 GDS42 pour ta piscine !'");
  console.log("Solde étudiant:", formatWhole(balanceAfterPiscine), "GDS42");

  console.log("\n--- Étape 2 : Projet validé à 125% ---");
  await goodiesToken.write.mint([student.account.address, 100n], {
    account: staff.account,
  });
  await goodies42Shop.write.grantAccess([student.account.address], {
    account: staff.account,
  });
  await goodies42Shop.write.setItemPrice([1n, 100n], {
    account: staff.account,
  });
  console.log("Staff: 'Incroyable, 125% ! Voici 100 GDS42 + 1 LotteryAccess.'");

  console.log("\n--- Étape 3 : Achat d'un goodie (itemId=1) ---");
  const price = await goodies42Shop.read.itemPrice([1n]);
  console.log("Prix on-chain item #1:", formatWhole(price), "GDS42");

  console.log("Étudiant: 'J'approuve le Shop pour dépenser mes tokens...' ");
  await goodiesToken.write.approve([shopAddress, price], {
    account: student.account,
  });

  console.log("Étudiant: 'Je tente la réponse bonus pour éviter le paiement...' ");
  await goodies42Shop.write.buy([1n, "42"], {
    account: student.account,
  });

  console.log("\n--- RÉSULTAT FINAL ---");
  const finalStudentBalance = await goodiesToken.read.balanceOf([student.account.address]);
  const finalShopBalance = await goodiesToken.read.balanceOf([shopAddress]);
  const accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);

  console.log("Solde final étudiant:", formatWhole(finalStudentBalance), "GDS42");
  console.log("Solde final shop:", formatWhole(finalShopBalance), "GDS42");
  console.log("LotteryAccess restant:", accessRemaining.toString());

  if (finalStudentBalance === 200n * DECIMALS && finalShopBalance === 0n) {
    console.log("SUCCÈS: bonne réponse => aucun paiement, l'étudiant garde ses tokens.");
  } else {
    console.log("INFO: paiement effectué (mauvaise réponse ou pas d'accès). Vérifie les logs.");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
