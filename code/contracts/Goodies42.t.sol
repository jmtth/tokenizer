// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Goodies42 } from "./Goodies42.sol";

// create a separate contract to test the minting and ownership 
// transfer restrictions of Goodies42
contract NonOwnerMinter {
  function tryMint(address token, address to, uint256 amount) external returns (bool) {
    (bool success, ) = token.call(
      abi.encodeWithSignature("mint(address,uint256)", to, amount)
    );
    return success;
  }

  function tryAcceptOwnership(address token) external returns (bool) {
    (bool success, ) = token.call(
      abi.encodeWithSignature("acceptOwnership()")
    );
    return success;
  }
}

contract Goodies42Test {
  Goodies42 goodies42;
  NonOwnerMinter nonOwner;

  address recipient = address(0xBEEF);

  function setUp() public {
    goodies42 = new Goodies42();
    nonOwner = new NonOwnerMinter();
  }

  // Verify that the token initializes with the expected name, symbol, decimals, owner, and total supply.
  function test_InitializesWithExpectedValues() public view {
    require(keccak256(bytes(goodies42.name())) == keccak256(bytes("Goodies42")), "invalid name");
    require(keccak256(bytes(goodies42.symbol())) == keccak256(bytes("GDS42")), "invalid symbol");
    require(goodies42.decimals() == 18, "invalid decimals");
    require(goodies42.Goodies42owner() == address(this), "invalid owner");
    require(goodies42.totalSupply() == 0, "total supply should start at 0");
  }

  // Verify that only the owner can mint and that the mint credits the correct amount (with decimals).
  function test_OnlyOwnerCanMint() public {
    bool success = nonOwner.tryMint(address(goodies42), recipient, 1);
    require(!success, "non-owner mint should fail");

    goodies42.mint(address(this), 1);
    require(goodies42.balanceOf(address(this)) == 1e18, "owner mint should succeed");
  }

  // Verify that transfers cannot exceed the balance.
  function test_TransferCannotExceedBalance() public {
    goodies42.mint(address(this), 100);

    bool transferSuccess = goodies42.transfer(recipient, 100 * 1e18);
    require(transferSuccess, "transfer at max balance should succeed");
    require(goodies42.balanceOf(address(this)) == 0, "owner balance should be 0 after transfer");
    require(goodies42.balanceOf(recipient) == 100 * 1e18, "recipient should receive transferred tokens");

    (bool shouldFail, ) = address(goodies42).call(
      abi.encodeWithSignature("transfer(address,uint256)", recipient, 1)
    );
    require(!shouldFail, "transfer above balance should fail");
  }

  // Verify the two-step ownership transfer and the associated owner rights.
  function test_TwoStepOwnershipTransfer() public {
    goodies42.transferOwnership(address(nonOwner));
    require(goodies42.pendingOwner() == address(nonOwner), "pending owner should be set");

    (bool acceptByCurrentOwner, ) = address(goodies42).call(
      abi.encodeWithSignature("acceptOwnership()")
    );
    require(!acceptByCurrentOwner, "current owner should not accept ownership");

    bool accepted = nonOwner.tryAcceptOwnership(address(goodies42));
    require(accepted, "pending owner should accept ownership");
    require(goodies42.Goodies42owner() == address(nonOwner), "owner should be updated");
    require(goodies42.pendingOwner() == address(0), "pending owner should be cleared");

    (bool oldOwnerMint, ) = address(goodies42).call(
      abi.encodeWithSignature("mint(address,uint256)", address(this), 1)
    );
    require(!oldOwnerMint, "old owner should not mint");

    bool newOwnerMint = nonOwner.tryMint(address(goodies42), recipient, 1);
    require(newOwnerMint, "new owner should mint");
    require(goodies42.balanceOf(recipient) == 1e18, "recipient should receive minted tokens");
  }
}