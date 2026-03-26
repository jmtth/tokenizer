// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Goodies42Management } from "./Goodies42multisig.sol";

contract NonManager{
    function tryToSubmitTransaction(address multisig) external returns (bool) {
        (bool success, ) = multisig.call(
            abi.encodeWithSignature("submitTransaction(address,uint256,bytes)", address(0x4), 0, "")
        );
        return success;
    }
    function tryToSignTransaction(address multisig, uint256 txIndex) external returns (bool) {
        (bool success, ) = multisig.call(
            abi.encodeWithSignature("signTransaction(uint256)", txIndex)
        );
        return success;
    }
    function tryToExecuteTransaction(address multisig, uint256 txIndex) external returns (bool) {
        (bool success, ) = multisig.call(
            abi.encodeWithSignature("executeTransaction(uint256)", txIndex)
        );
        return success;
    }
    function tryToUnsignTransaction(address multisig, uint256 txIndex) external returns (bool) {
        (bool success, ) = multisig.call(
            abi.encodeWithSignature("unsignTransaction(uint256)", txIndex)
        );
        return success;
    }
    function tryToAddManager(address multisig, address newManager) external returns (bool) {
        (bool success, ) = multisig.call(
            abi.encodeWithSignature("addManager(address)", newManager)
        );
        return success;
    }
    function tryToRemoveManager(address multisig, address oldManager) external returns (bool) {
        (bool success, ) = multisig.call(
            abi.encodeWithSignature("removeManager(address)", oldManager)
        );
        return success;
    }
}

contract Manager2Caller {
    function signTransaction(address multisig, uint256 txIndex) external returns (bool) {
        (bool success, ) = multisig.call(
            abi.encodeWithSignature("signTransaction(uint256)", txIndex)
        );
        return success;
    }
}

contract Goodies42multisdigTest{
    Goodies42Management multisig;
    address manager1 = address(this);
    address manager2;
    address manager3 = address(0x6);
    NonManager nonManager;
    Manager2Caller manager2Caller;

    function setUp() public {
        manager2Caller = new Manager2Caller();
        manager2 = address(manager2Caller);
        address[] memory managers = new address[](3);
        managers[0] = manager1;
        managers[1] = manager2;
        managers[2] = manager3;
        multisig = new Goodies42Management(managers, 2);
        nonManager = new NonManager();
    }

    // helpers 
    function _executeTxShouldSucceed(uint256 _txIndex, string memory err) internal {
        (bool success,) = address(multisig).call(
            abi.encodeWithSignature("executeTransaction(uint256)", _txIndex)
        );
        require(success, err);
    }

    function _executeTxShouldFail(uint256 _txIndex, string memory err) internal {
        (bool success,) = address(multisig).call(
            abi.encodeWithSignature("executeTransaction(uint256)", _txIndex)
        );
        require(!success, err);
    }


    function test_OnlyManagersCanSubmitTransaction() public {
        // non-manager should not be able to submit a transaction
        bool failed = ! nonManager.tryToSubmitTransaction(address(multisig));
        require(failed, "Nonmanager should not be able to submit transaction");
        // manager should be able to submit a transaction
        (bool success, ) = address(multisig).call(
            abi.encodeWithSignature("submitTransaction(address,uint256,bytes)", address(0x4), 0, "")        );
        require(success, "Manager should be able to submit transaction");
    }

    function test_OnlyManagersCanSignTransaction() public {
        // submit a transaction
        multisig.submitTransaction(address(0x4), 0, "");
        // non-manager should not be able to sign the transaction
        bool failed = ! nonManager.tryToSignTransaction(address(multisig), 0);
        require(failed, "Nonmanager should not be able to sign transaction");
        // manager should be able to sign the transaction
        (bool success, ) = address(multisig).call(
            abi.encodeWithSignature("signTransaction(uint256)", 0)
        );
        require(success, "Manager should be able to sign transaction");
    }

    function test_OnlyManagersCanExecuteTransaction() public {
        // submit a transaction
        multisig.submitTransaction(address(0x4), 0, "");
        // sign the transaction with both managers
        multisig.signTransaction(0);
        bool manager2Signed = manager2Caller.signTransaction(address(multisig), 0);
        require(manager2Signed, "Manager2 should be able to sign transaction");
        // non-manager should not be able to execute the transaction
        bool failed = ! nonManager.tryToExecuteTransaction(address(multisig), 0);
        require(failed, "Nonmanager should not be able to execute transaction");
        // manager should be able to execute the transaction
        (bool success, ) = address(multisig).call(
            abi.encodeWithSignature("executeTransaction(uint256)", 0)
        );
        require(success, "Manager should be able to execute transaction");
    }
    function test_OnlyTransactionWithEnoughSignaturesCanBeExecuted() public {
        // submit a transaction
        multisig.submitTransaction(address(0x4), 0, "");
        // sign the transaction with both managers
        multisig.signTransaction(0);
        // manager should not be able to execute the transaction
        (bool success, ) = address(multisig).call(
            abi.encodeWithSignature("executeTransaction(uint256)", 0)
        );
        require(!success, "Manager should not be able to execute transaction");
    }

    function test_OnlyManagersCanUnsignTransaction() public {
        // submit a transaction
        multisig.submitTransaction(address(0x4), 0, "");
        // sign the transaction with both managers
        multisig.signTransaction(0);
        manager2Caller.signTransaction(address(multisig), 0);
        // non-manager should not be able to unsign the transaction
        bool failed = ! nonManager.tryToUnsignTransaction(address(multisig), 0);
        require(failed, "Nonmanager should not be able to unsign transaction");
        // manager should be able to unsign the transaction
        (bool success, ) = address(multisig).call(
            abi.encodeWithSignature("unsignTransaction(uint256)", 0)
        );
        require(success, "Manager should be able to unsign transaction");
    }

    function test_AddManagerRequireEnoughSignatures() public {
        //Encode the internal method protected by onlyGoodiesManagement
        bytes memory data = abi.encodeWithSignature("addManager(address)", address(nonManager));
        multisig.submitTransaction(address(multisig), 0, data); 
        multisig.signTransaction(0);
        //A manager cannot add another manager without the required number of signatures
        (bool failed, ) = address(multisig).call(
            abi.encodeWithSignature("executeTransaction(uint256)", 0)
        );
        failed = !failed;
        require(failed, "Adding a manager requires enough signatures");
        manager2Caller.signTransaction(address(multisig), 0);
        // A manager should be able to add a manager with enough signatures
       (bool success, ) = address(multisig).call(
            abi.encodeWithSignature("executeTransaction(uint256)", 0)
        );
        require(success, "A manager should be able to add a manager with enough signatures");
        require(multisig.isManager(address(nonManager)), "nonManager should now be a manager");
    }

    function test_RemoveManagerRequireEnoughSignatures() public {
        // Encode the internal method protected by onlyGoodiesManagement
        bytes memory data = abi.encodeWithSignature("removeManager(address)", manager3);
        require(multisig.isManager(manager3),"Manager3 should be a manager before being removed");
        // Submit the transation removeManager
        multisig.submitTransaction(address(multisig), 0, data);
        multisig.signTransaction(0);
        _executeTxShouldFail(0, "Removing a manager requires enough signatures");
        manager2Caller.signTransaction(address(multisig), 0);
        _executeTxShouldSucceed(0, "A manager should be able to remove a manager with enough signatures");
        bool isAManager = multisig.isManager(manager3);
        require(!isAManager, "Manager3 should not be a manager anymore");
    }
    
    function test_MangerCantRemoveHimself() public {
        // manager should not be able to remove himself manager1 is this
        // Encode the internal method protected by onlyGoodiesManagement
        bytes memory data = abi.encodeWithSignature("removeManager(address)", manager1);
        // Submit the transation removeManager
        multisig.submitTransaction(address(multisig), 0, data);
        multisig.signTransaction(0);
        manager2Caller.signTransaction(address(multisig), 0);
        _executeTxShouldSucceed(0, "Manager should not be able to remove himself");
    }

    function test_CannotRemoveManagerIfNotEnoughManagersLeft() public {
        // manager should not be able to remove a manager if not enough managers left
        bytes memory data1 = abi.encodeWithSignature("removeManager(address)", manager3);
        // Submit the transation removeManager
        multisig.submitTransaction(address(multisig), 0, data1);
        multisig.signTransaction(0);
        manager2Caller.signTransaction(address(multisig), 0);
        _executeTxShouldSucceed(0, "A manager should be able to remove a manager with enough signatures");
        bytes memory data2 = abi.encodeWithSignature("removeManager(address)", manager2);
        // Submit the transation removeManager
        multisig.submitTransaction(address(multisig), 0, data2);
        multisig.signTransaction(1);
        manager2Caller.signTransaction(address(multisig), 1);
        _executeTxShouldFail(1, "Manager should not be able to remove manager if not enough managers left");
    }
}