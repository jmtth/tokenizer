// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Goodies42Shop } from "./Goodies42Shop.sol";
import { Goodies42 } from "./Goodies42.sol";

contract NonOwner {
    function tryAcceptOwnership(address shop) external returns (bool) {
    (bool success, ) = shop.call(
      abi.encodeWithSignature("acceptOwnership()")
    );
    return success;
    }

    function tryGrantAccess(address shop, address student) external returns (bool){
        (bool success, ) = shop.call(
            abi.encodeWithSignature("grantAccess", student)
        );
        return success;
    }

    function trySetItemPrice(address shop, uint256 itemId, uint256 priceInTokens) external returns (bool) {
        (bool success, ) = shop.call(
            abi.encodeWithSignature("setItemPrice", itemId, priceInTokens)
        );
        return success;
    }
}

contract Goodies42ShopTest {
    Goodies42 goodies42;
    Goodies42Shop goodies42Shop;
    NonOwner nonOwner;

    address student = address(0xBEEF);
    address staff = address(this);

    function setUp() public {
        goodies42 = new Goodies42();
        goodies42Shop = new Goodies42Shop(address(goodies42));
        nonOwner = new NonOwner();
    }

    function test_InitializesWithExpectedValues() public view {
        require(goodies42Shop.owner() == address(this), "invalid owner");
        require(address(goodies42Shop.token()) == address(goodies42), "invalid token address");
        require(goodies42Shop.MAX_LOTTERY_ACCESS() == 3, "invalid max lottery access");
        require(goodies42Shop.itemPrice(1) == 0, "initial item price should be 0");
        require(goodies42Shop.userLotteryAccessCount(student) == 0, "initial lottery access count should be 0");
        require(goodies42Shop.userAvailableLotteryAccessCount(student) == 0, "initial available lottery access count should be 0");
        require(keccak256(bytes(goodies42.name())) == keccak256(bytes("Goodies42")), "token name should be Goodies42");
        require(goodies42Shop.HASH_ANSWER() == keccak256(abi.encodePacked("42")), "invalid answer hash");
    }

    function test_OnlyOwnerCanTransferOwnerShip() public{
        goodies42Shop.transferOwnership(address(nonOwner));
        require(goodies42Shop.pendingOwner() == address(nonOwner), "pending owner should be set");
        (bool acceptByCurrentOwner, ) = address(goodies42Shop).call(
            abi.encodeWithSignature("acceptOwnership()")
        );
        require(!acceptByCurrentOwner, "current owner should not accept ownership");
        bool success = nonOwner.tryAcceptOwnership(address(goodies42Shop));
        require(success, "pending owner should accept ownership");
        require(goodies42Shop.owner() == address(nonOwner), "owner should be updated to pending owner");
        require(goodies42Shop.pendingOwner() == address(0), "pending owner should be reset after acceptance");
    }

    function test_OnlyOwnerCanGrantAccess()  public {
        bool successNonOwner = nonOwner.tryGrantAccess(address(goodies42Shop), student);
        require(!successNonOwner, "non-owner should not grant access");
        goodies42Shop.grantAccess(student);
        require(goodies42Shop.userLotteryAccessCount(student) == 1, "student should have 1 access");
    }

    function test_OnlyOwnerCanSetItemPrice() public {
        bool successNonOwner = nonOwner.trySetItemPrice(address(goodies42Shop), 1, 42);
        require(!successNonOwner, "non-owner should not set item price");
        goodies42Shop.setItemPrice(1, 42);
        require(goodies42Shop.itemPrice(1) == 42 * 10**18, "item price should be set correctly");
    }

}