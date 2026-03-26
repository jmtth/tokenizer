import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";

describe("Goodies42multisig (Typescript test)", async ()=>{
    const { viem } = await network.connect();

    async function setUp(){
        const [manager1, manager2, manager3, nonManager] = await viem.getWalletClients();
        const goodies42multisig = await viem.deployContract("Goodies42Management",[[manager1.account.address, manager2.account.address], 2n]);
        return {goodies42multisig, manager1, manager2, manager3, nonManager};
    }

    it ("Only managers can submit transaction", async () =>{
        const {goodies42multisig, manager1, manager2, nonManager} = await setUp();
        await goodies42multisig.write.submitTransaction([manager2.account.address, 0n, "0x"], {account: manager1.account});
        await assert.rejects(
            goodies42multisig.write.submitTransaction([manager2.account.address, 0n, "0x"], {account: nonManager.account})
        );
    });

    it ("Only managers can sign transaction", async () =>{
        const {goodies42multisig, manager1, manager2, nonManager} = await setUp();
        await goodies42multisig.write.submitTransaction([manager2.account.address, 0n, "0x"], {account: manager1.account});
        await goodies42multisig.write.signTransaction([0n], {account: manager2.account});
        await assert.rejects(
            goodies42multisig.write.signTransaction([0n], {account: nonManager.account})
        );
    });

    it ("Transaction requires enough signatures", async () =>{
        const {goodies42multisig, manager1, manager2} = await setUp();
        await goodies42multisig.write.submitTransaction([manager1.account.address, 0n, "0x01"], {account: manager1.account});
        await goodies42multisig.write.signTransaction([0n], {account: manager1.account});
        await assert.rejects(
            goodies42multisig.write.executeTransaction([0n], {account: manager1.account})
        );
        await goodies42multisig.write.signTransaction([0n], {account: manager2.account});
        await assert.ok(
            goodies42multisig.write.executeTransaction([0n], {account: manager1.account})
        );
    });

    it ("Cannot execute transaction twice", async () =>{
        const {goodies42multisig, manager1, manager2} = await setUp();
        await goodies42multisig.write.submitTransaction([manager1.account.address, 0n, "0x01"], {account: manager1.account});
        await goodies42multisig.write.signTransaction([0n], {account: manager1.account});
        await goodies42multisig.write.signTransaction([0n], {account: manager2.account});
        await goodies42multisig.write.executeTransaction([0n], {account: manager1.account});
        await assert.rejects(
            goodies42multisig.write.executeTransaction([0n], {account: manager1.account})
        );
    });

    it ("Cannot sign transaction twice", async () =>{
        const {goodies42multisig, manager1} = await setUp();
        await goodies42multisig.write.submitTransaction([manager1.account.address, 0n, "0x01"], {account: manager1.account});
        await goodies42multisig.write.signTransaction([0n], {account: manager1.account});
        await assert.rejects(
            goodies42multisig.write.signTransaction([0n], {account: manager1.account})
        );
    });

    it ("Cannot execute nonexistent transaction", async () =>{
        const {goodies42multisig, manager1} = await setUp();
        await assert.rejects(
            goodies42multisig.write.executeTransaction([0n], {account: manager1.account})
        );
    });

    it ("Cannot sign nonexistent transaction", async () =>{
        const {goodies42multisig, manager1} = await setUp();
        await assert.rejects(
            goodies42multisig.write.signTransaction([0n], {account: manager1.account})
        );  
    });

    it ("Cannot submit transaction to zero address", async () =>{
        const {goodies42multisig, manager1} = await setUp();
        await assert.rejects(
            goodies42multisig.write.submitTransaction(["0x0", 0n, "0x"], {account: manager1.account})
        );  
     });

     it ("Cannnot unsign a transaction when not signed", async () =>{
        const {goodies42multisig, manager1} = await setUp();
        await goodies42multisig.write.submitTransaction([manager1.account.address, 0n, "0x01"],{account: manager1.account});
        await assert.rejects(
            goodies42multisig.write.unsignTransaction([0n],{account: manager1.account} )
        );
    });
     
    it ("Return the correct count of transactions", async () =>{
        const {goodies42multisig, manager1} = await setUp();
        await goodies42multisig.write.submitTransaction([manager1.account.address, 0n, "0x01"],{account: manager1.account});
        await goodies42multisig.write.submitTransaction([manager1.account.address, 0n, "0x01"],{account: manager1.account});
        const count = await goodies42multisig.read.getTransactionCount();
        assert.equal(count, 2n);
    });

    it ("Return the correct transaction details", async () =>{
        const {goodies42multisig, manager1} = await setUp();
        await goodies42multisig.write.submitTransaction([manager1.account.address, 0n, "0x01"],{account: manager1.account});
        const [to, value, data, executed] = await goodies42multisig.read.getTransaction([0n]);
        assert.equal(to.toLowerCase(), manager1.account.address.toLowerCase());
        assert.equal(value, 0n);
        assert.equal(data, "0x01");
        assert.equal(executed, false);
    });

    it("emits Deposit on plain ETH transfer", async () => {
        const { goodies42multisig, manager1 } = await setUp();
        const depositAmount = 1n * 10n ** 18n; // 1 ETH

        const publicClient = await viem.getPublicClient();
        const balanceBefore = await publicClient.getBalance({
            address: goodies42multisig.address,
        });

        const txHash = await manager1.sendTransaction({
            to: goodies42multisig.address,
            value: depositAmount,
        });

        await publicClient.waitForTransactionReceipt({ hash: txHash });
        const balanceAfter = await publicClient.getBalance({
            address: goodies42multisig.address,
        });

        assert.equal(balanceAfter - balanceBefore, depositAmount);
    });

    

});