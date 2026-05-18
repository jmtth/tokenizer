import { network } from "hardhat";

const DECIMALS = 10n ** 18n;
const VERT = "\x1b[32m";
const RESET = "\x1b[0m";
const GRAS_ = "\x1b[1;4m";


function formatWhole(amount) {
  return (amount / DECIMALS).toString();
}

async function main() {
  const { viem } = await network.connect();

  const [staff, student] = await viem.getWalletClients();
  console.log(VERT + "--- Initialisation de la simulation 42 ---" + RESET);
  console.log(GRAS_ + "Staff (Admin):" + RESET, staff.account.address);
  console.log(GRAS_ + "Étudiant:" + RESET, student.account.address);

  const goodiesToken = await viem.deployContract("Goodies42");
  const tokenAddress = goodiesToken.address;
  console.log("\n[1] Token GOODIES42 déployé à:", tokenAddress);

  const goodies42Shop = await viem.deployContract("Goodies42Shop", [tokenAddress]);
  const shopAddress = goodies42Shop.address;
  console.log("[2] Shop déployé à:", shopAddress);

  console.log("\n" + VERT + "--- Étape 1 : Fin de Piscine ---" + RESET);
  await goodiesToken.write.mint([student.account.address, 100n], {
    account: staff.account,
  });
  const balanceAfterPiscine = await goodiesToken.read.balanceOf([student.account.address]);
  console.log(GRAS_ + "Staff:" + RESET + " 'Bravo, voici 100 GDS42 pour ta piscine !'");
  console.log(GRAS_ + "Solde étudiant:" + RESET + " ", formatWhole(balanceAfterPiscine), "GDS42");

  console.log("\n" + VERT + "--- Étape 2 : Projet validé à 125% ---" + RESET);
  await goodiesToken.write.mint([student.account.address, 100n], {
    account: staff.account,
  });
  await goodies42Shop.write.grantAccess([student.account.address], {
    account: staff.account,
  });
  await goodies42Shop.write.setItemPrice([1n, 100n], {
    account: staff.account,
  });
  console.log(GRAS_ + "Staff:" + RESET + " 'Incroyable, 125% ! Voici 100 GDS42 + 1 LotteryAccess.'");

  let accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);
  console.log(GRAS_ + "LotteryAccess de l'étudiant:" + RESET + " ", accessRemaining.toString());

  console.log("\n" + VERT + "--- Étape 3 : Achat d'un goodie (itemId=1) ---" + RESET);
  let price = await goodies42Shop.read.itemPrice([1n]);
  console.log(GRAS_ + "Prix on-chain item #1:" + RESET + " ", formatWhole(price), "GDS42");

  console.log(GRAS_ + "Étudiant:" + RESET + " 'J'approuve le Shop pour dépenser mes tokens...' ");
  await goodiesToken.write.approve([shopAddress, price], {
    account: student.account,
  });

  console.log(GRAS_ + "Étudiant:" + RESET + " 'Je tente la réponse bonus pour éviter le paiement...' ");
  await goodies42Shop.write.buy([1n, "42"], {
    account: student.account,
  });

  console.log("\n" + VERT + "--- RÉSULTAT FINAL ---" + RESET);
  let finalStudentBalance = await goodiesToken.read.balanceOf([student.account.address]);
  let finalShopBalance = await goodiesToken.read.balanceOf([shopAddress]);
  accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);

  console.log(GRAS_ + "Solde final étudiant:" + RESET + " ", formatWhole(finalStudentBalance), "GDS42");
  console.log(GRAS_ + "Solde final shop:" + RESET + " ", formatWhole(finalShopBalance), "GDS42");
  console.log(GRAS_ + "LotteryAccess restant:" + RESET + " ", accessRemaining.toString());

  if (finalStudentBalance === 200n * DECIMALS && finalShopBalance === 0n) {
    console.log(GRAS_ + "SUCCÈS:" + RESET + " bonne réponse => aucun paiement, l'étudiant garde ses tokens.");
  } else {
    console.log(GRAS_ + "INFO:" + RESET + " paiement effectué (mauvaise réponse ou pas d'accès). Vérifie les logs.");
  }

  console.log("\n" + VERT + "--- Étape 4 : Achat d'un deuxième goodie (itemId=1) ---" + RESET);
  price = await goodies42Shop.read.itemPrice([1n]);
  console.log(GRAS_ + "Prix on-chain item #1:" + RESET + " ", formatWhole(price), "GDS42");

  console.log(GRAS_ + "Étudiant:" + RESET + " 'J'approuve le Shop pour dépenser mes tokens...' ");
  await goodiesToken.write.approve([shopAddress, price], {
    account: student.account,
  });

  console.log(GRAS_ + "Shop:" + RESET + " 'execute l'achat' ");
  await goodies42Shop.write.buy([1n, ""], {
    account: student.account,
  });
  console.log("\n" + VERT + "--- RÉSULTAT FINAL ---" + RESET);
  finalStudentBalance = await goodiesToken.read.balanceOf([student.account.address]);
  finalShopBalance = await goodiesToken.read.balanceOf([shopAddress]);
  accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);

  console.log(GRAS_ + "Solde final étudiant:" + RESET + " ", formatWhole(finalStudentBalance), "GDS42");
  console.log(GRAS_ + "Solde final shop:" + RESET + " ", formatWhole(finalShopBalance), "GDS42");
  console.log(GRAS_ + "LotteryAccess restant:" + RESET, accessRemaining.toString());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
