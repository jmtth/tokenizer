import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";

describe("Goodies42 (TypeScript tests)", async () => {
  const { viem } = await network.connect();

  // Verifies initial values: name, symbol, decimals, owner, and totalSupply.
  it("initializes with expected values", async () => {
    const goodies42 = await viem.deployContract("Goodies42");

    const name = await goodies42.read.name();
    const symbol = await goodies42.read.symbol();
    const decimals = await goodies42.read.decimals();
    const owner = await goodies42.read.Goodies42owner();
    const supply = await goodies42.read.totalSupply();

    const [deployer] = await viem.getWalletClients();

    assert.equal(name, "Goodies42");
    assert.equal(symbol, "GDS42");
    assert.equal(decimals, 18);
    assert.equal(owner.toLowerCase(), deployer.account.address.toLowerCase());
    assert.equal(supply, 0n);
  });

  // Verifies that only the owner can mint tokens.
  it("allows only owner to mint", async () => {
    const goodies42 = await viem.deployContract("Goodies42");
    const [owner, nonOwner] = await viem.getWalletClients();

    await goodies42.write.mint([owner.account.address, 1n], {
      account: owner.account,
    });

    const ownerBalance = await goodies42.read.balanceOf([owner.account.address]);
    assert.equal(ownerBalance, 10n ** 18n);

    await assert.rejects(
      goodies42.write.mint([nonOwner.account.address, 1n], {
        account: nonOwner.account,
      })
    );
  });

  // Verifies that a transfer succeeds up to the available balance, then fails beyond it.
  it("transfers up to available balance only", async () => {
    const goodies42 = await viem.deployContract("Goodies42");
    const [owner, recipient] = await viem.getWalletClients();

    await goodies42.write.mint([owner.account.address, 100n], {
      account: owner.account,
    });

    const maxAmount = 100n * 10n ** 18n;

    await goodies42.write.transfer([recipient.account.address, maxAmount], {
      account: owner.account,
    });

    const ownerBalanceAfterMax = await goodies42.read.balanceOf([owner.account.address]);
    const recipientBalance = await goodies42.read.balanceOf([recipient.account.address]);

    assert.equal(ownerBalanceAfterMax, 0n);
    assert.equal(recipientBalance, maxAmount);

    await assert.rejects(
      goodies42.write.transfer([recipient.account.address, 1n], {
        account: owner.account,
      })
    );
  });

  // Demonstrates the classic ERC20 approve -> transferFrom flow (spending delegation).
  it("approve then transferFrom lets a spender move tokens", async () => {
    const goodies42 = await viem.deployContract("Goodies42");
    const [owner, spender, recipient] = await viem.getWalletClients();

    await goodies42.write.mint([owner.account.address, 100n], {
      account: owner.account,
    });

    await goodies42.write.approve([spender.account.address, 30n * 10n ** 18n], {
      account: owner.account,
    });

    await goodies42.write.transferFrom(
      [owner.account.address, recipient.account.address, 20n * 10n ** 18n],
      { account: spender.account }
    );

    const remainingAllowance = await goodies42.read.allowance([
      owner.account.address,
      spender.account.address,
    ]);
    const ownerBalance = await goodies42.read.balanceOf([owner.account.address]);
    const recipientBalance = await goodies42.read.balanceOf([recipient.account.address]);

    assert.equal(remainingAllowance, 10n * 10n ** 18n);
    assert.equal(ownerBalance, 80n * 10n ** 18n);
    assert.equal(recipientBalance, 20n * 10n ** 18n);

    await assert.rejects(
      goodies42.write.transferFrom(
        [owner.account.address, recipient.account.address, 11n * 10n ** 18n],
        { account: spender.account }
      )
    );
  });

  // Verifies the 2-step ownership transfer: proposal + acceptance.
  it("supports two-step ownership transfer", async () => {
    const goodies42 = await viem.deployContract("Goodies42");
    const [currentOwner, nextOwner, outsider] = await viem.getWalletClients();

    await goodies42.write.transferOwnership([nextOwner.account.address], {
      account: currentOwner.account,
    });

    const pendingOwner = await goodies42.read.pendingOwner();
    assert.equal(pendingOwner.toLowerCase(), nextOwner.account.address.toLowerCase());

    await assert.rejects(
      goodies42.write.acceptOwnership({
        account: outsider.account,
      })
    );

    await goodies42.write.acceptOwnership({
      account: nextOwner.account,
    });

    const ownerAfter = await goodies42.read.Goodies42owner();
    const pendingAfter = await goodies42.read.pendingOwner();
    assert.equal(ownerAfter.toLowerCase(), nextOwner.account.address.toLowerCase());
    assert.equal(pendingAfter, "0x0000000000000000000000000000000000000000");

    await assert.rejects(
      goodies42.write.mint([currentOwner.account.address, 1n], {
        account: currentOwner.account,
      })
    );

    await goodies42.write.mint([nextOwner.account.address, 1n], {
      account: nextOwner.account,
    });
  });
});
