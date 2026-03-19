import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";

describe("Liberty (TypeScript tests)", async () => {
  const { viem } = await network.connect();

  // Vérifie les valeurs initiales: nom, symbole, decimals, owner et totalSupply.
  it("initializes with expected values", async () => {
    const liberty = await viem.deployContract("Liberty", ["Liberty", "LIB", 18]);

    const name = await liberty.read.name();
    const symbol = await liberty.read.symbol();
    const decimals = await liberty.read.decimals();
    const owner = await liberty.read.Libertyowner();
    const supply = await liberty.read.totalSupply();

    const [deployer] = await viem.getWalletClients();

    assert.equal(name, "Liberty");
    assert.equal(symbol, "LIB");
    assert.equal(decimals, 18);
    assert.equal(owner.toLowerCase(), deployer.account.address.toLowerCase());
    assert.equal(supply, 0n);
  });

  // Vérifie que seul le owner peut mint des tokens.
  it("allows only owner to mint", async () => {
    const liberty = await viem.deployContract("Liberty", ["Liberty", "LIB", 18]);
    const [owner, nonOwner] = await viem.getWalletClients();

    await liberty.write.mint([owner.account.address, 1n], {
      account: owner.account,
    });

    const ownerBalance = await liberty.read.balanceOf([owner.account.address]);
    assert.equal(ownerBalance, 10n ** 18n);

    await assert.rejects(
      liberty.write.mint([nonOwner.account.address, 1n], {
        account: nonOwner.account,
      })
    );
  });

  // Vérifie qu'un transfert est possible jusqu'au solde, puis échoue au-delà.
  it("transfers up to available balance only", async () => {
    const liberty = await viem.deployContract("Liberty", ["Liberty", "LIB", 18]);
    const [owner, recipient] = await viem.getWalletClients();

    await liberty.write.mint([owner.account.address, 100n], {
      account: owner.account,
    });

    const maxAmount = 100n * 10n ** 18n;

    await liberty.write.transfer([recipient.account.address, maxAmount], {
      account: owner.account,
    });

    const ownerBalanceAfterMax = await liberty.read.balanceOf([owner.account.address]);
    const recipientBalance = await liberty.read.balanceOf([recipient.account.address]);

    assert.equal(ownerBalanceAfterMax, 0n);
    assert.equal(recipientBalance, maxAmount);

    await assert.rejects(
      liberty.write.transfer([recipient.account.address, 1n], {
        account: owner.account,
      })
    );
  });

  // Montre le flux ERC20 classique approve -> transferFrom (délégation de dépense).
  it("approve then transferFrom lets a spender move tokens", async () => {
    const liberty = await viem.deployContract("Liberty", ["Liberty", "LIB", 18]);
    const [owner, spender, recipient] = await viem.getWalletClients();

    await liberty.write.mint([owner.account.address, 100n], {
      account: owner.account,
    });

    await liberty.write.approve([spender.account.address, 30n * 10n ** 18n], {
      account: owner.account,
    });

    await liberty.write.transferFrom(
      [owner.account.address, recipient.account.address, 20n * 10n ** 18n],
      { account: spender.account }
    );

    const remainingAllowance = await liberty.read.allowance([
      owner.account.address,
      spender.account.address,
    ]);
    const ownerBalance = await liberty.read.balanceOf([owner.account.address]);
    const recipientBalance = await liberty.read.balanceOf([recipient.account.address]);

    assert.equal(remainingAllowance, 10n * 10n ** 18n);
    assert.equal(ownerBalance, 80n * 10n ** 18n);
    assert.equal(recipientBalance, 20n * 10n ** 18n);

    await assert.rejects(
      liberty.write.transferFrom(
        [owner.account.address, recipient.account.address, 11n * 10n ** 18n],
        { account: spender.account }
      )
    );
  });
});
