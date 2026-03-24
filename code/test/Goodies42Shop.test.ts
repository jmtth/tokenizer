import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";

describe ("goodies42Shop (TypeScript tests)", async () => {
  const { viem } = await network.connect();

  async function setupShopPurchaseContext(withAccess: boolean = true) {
    const goodies42 = await viem.deployContract("Goodies42");
    const goodies42Shop = await viem.deployContract("Goodies42Shop", [goodies42.address]);
    const [staff, student] = await viem.getWalletClients();

    await goodies42.write.mint([student.account.address, 100n], {
      account: staff.account,
    });
    if (withAccess) {
      await goodies42Shop.write.grantAccess([student.account.address], {
        account: staff.account,
      });
    }
    await goodies42Shop.write.setItemPrice([1n, 50n], {
      account: staff.account,
    });

    return { goodies42, goodies42Shop, staff, student };
  }

  // Verifies paid purchase flow: student has access but wrong answer triggers token payment.
  it("allows buying an item with correct payment normal way", async () => {
    const { goodies42, goodies42Shop, student } = await setupShopPurchaseContext(false);

    await goodies42.write.approve([goodies42Shop.address, 50n * 10n ** 18n], {
      account: student.account,
    });

    // Attempt to buy item #1
    await goodies42Shop.write.buy([1n, "wrong-answer"], {
      account: student.account,
    });

    // Verify balances and access
    const studentBalance = await goodies42.read.balanceOf([student.account.address]);
    const shopBalance = await goodies42.read.balanceOf([goodies42Shop.address]);
    const accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);

    assert.equal(studentBalance, 50n * 10n ** 18n);
    assert.equal(shopBalance, 50n * 10n ** 18n);
    assert.equal(accessRemaining, 0n);
  });

  it ("allows buying an item with lottery access and correct answer, without payment", async () => {
    const { goodies42, goodies42Shop, student } = await setupShopPurchaseContext();
    await goodies42.write.approve([goodies42Shop.address, 50n * 10n ** 18n],{ account: student.account});
    await goodies42Shop.write.buy([1n, "42"], {account: student.account});
    // Verify balances and access
    const studentBalance = await goodies42.read.balanceOf([student.account.address]);
    const shopBalance = await goodies42.read.balanceOf([goodies42Shop.address]);
    const accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);

    assert.equal(studentBalance, 100n * 10n ** 18n);
    assert.equal(shopBalance, 0n);
    assert.equal(accessRemaining, 0n);
  });

  it ("allows buying an item with lottery access and wrong answer, with payment", async () => {
    const { goodies42, goodies42Shop, student } = await setupShopPurchaseContext();
    await goodies42.write.approve([goodies42Shop.address, 50n * 10n ** 18n],{ account: student.account});
    await goodies42Shop.write.buy([1n, "wrong-answer"], {account: student.account});
    // Verify balances and access
    const studentBalance = await goodies42.read.balanceOf([student.account.address]);
    const shopBalance = await goodies42.read.balanceOf([goodies42Shop.address]);
    const accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);

    assert.equal(studentBalance, 50n * 10n ** 18n);
    assert.equal(shopBalance, 50n * 10n ** 18n);
    assert.equal(accessRemaining, 0n);
  });

  it("prevents having more than three Lottery access", async () => {
    const { goodies42Shop, staff, student } = await setupShopPurchaseContext();

    // setup already grants 1 access, these two calls bring it to 3
    await goodies42Shop.write.grantAccess([student.account.address], { account: staff.account });
    await goodies42Shop.write.grantAccess([student.account.address], { account: staff.account });

    const before = await goodies42Shop.read.userAvailableLotteryAccessCount([student.account.address]);
    assert.equal(before, 3n);

    // 4th grant must revert
    await assert.rejects(
      goodies42Shop.write.grantAccess([student.account.address], { account: staff.account }),
      /LotteryAccess max reached/
    );

    const after = await goodies42Shop.read.userAvailableLotteryAccessCount([student.account.address]);
    assert.equal(after, 3n);
    const accessRemaining = await goodies42Shop.read.userLotteryAccessCount([student.account.address]);
    assert.equal(accessRemaining, 3n);
  });

    
});