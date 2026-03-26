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
            abi.encodeWithSignature("grantAccess(address)", student)
        );
        return success;
    }

    function trySetItemPrice(address shop, uint256 itemId, uint256 priceInTokens) external returns (bool) {
        (bool success, ) = shop.call(
            abi.encodeWithSignature("setItemPrice(uint256,uint256)", itemId, priceInTokens)
        );
        return success;
    }
}

contract Student {
    function tryApprove(address token, address spender, uint256 amount) external returns (bool) {
        (bool success, ) = token.call(
            abi.encodeWithSignature("approve(address,uint256)", spender, amount)
        );
        return success;
    }

    function tryBuy(address shop, uint256 itemId, string memory answer) external returns (bool) {
        (bool success, ) = shop.call(
            abi.encodeWithSignature("buy(uint256,string)", itemId, answer)
        );
        return success;
    }
}

contract Goodies42ShopTest {
    Goodies42 goodies42;
    Goodies42Shop goodies42Shop;
    NonOwner nonOwner;
    Student student;

    // address student = address(0xBEEF);
    address staff = address(this);

    function setUp() public {
        goodies42 = new Goodies42();
        goodies42.mint(goodies42.Goodies42owner(), 420000000);
        goodies42Shop = new Goodies42Shop(address(goodies42));
        nonOwner = new NonOwner();
        student = new Student();
    }

    function test_InitializesWithExpectedValues() public view {
        require(goodies42Shop.owner() == address(this), "invalid owner");
        require(address(goodies42Shop.token()) == address(goodies42), "invalid token address");
        require(goodies42Shop.MAX_LOTTERY_ACCESS() == 3, "invalid max lottery access");
        require(goodies42Shop.itemPrice(1) == 0, "initial item price should be 0");
        require(goodies42Shop.userLotteryAccessCount(address(student)) == 0, "initial lottery access count should be 0");
        require(goodies42Shop.userAvailableLotteryAccessCount(address(student)) == 0, "initial available lottery access count should be 0");
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
        bool successNonOwner = nonOwner.tryGrantAccess(address(goodies42Shop), address(student));
        require(!successNonOwner, "non-owner should not grant access");
        goodies42Shop.grantAccess(address(student));
        require(goodies42Shop.userLotteryAccessCount(address(student)) == 1, "student should have 1 access");
    }

    function test_OnlyOwnerCanSetItemPrice() public {
        bool successNonOwner = nonOwner.trySetItemPrice(address(goodies42Shop), 1, 42);
        require(!successNonOwner, "non-owner should not set item price");
        goodies42Shop.setItemPrice(1, 42);
        require(goodies42Shop.itemPrice(1) == 42 * 10**18, "item price should be set correctly");
    }

    function test_StudentWithNoAccesPay() public {
        goodies42.transfer(address(student), 100 * 10**18);
        goodies42Shop.setItemPrice(1, 50);
        bool approveSuccess = student.tryApprove(address(goodies42), address(goodies42Shop), 50 * 10**18);
        require(approveSuccess, "approve should succeed");

        bool buySuccess = student.tryBuy(address(goodies42Shop), 1, "");
        require(buySuccess, "buy should succeed");
        require(goodies42.balanceOf(address(student)) == 50 * 10**18, "balance of student should be 50");
    }

    function test_studentWithAccessAndGoodAnswer() public{
       goodies42.transfer(address(student), 100 * 10**18);
        goodies42Shop.setItemPrice(1, 50);
        bool approveSuccess = student.tryApprove(address(goodies42), address(goodies42Shop), 50 * 10**18);
        require(approveSuccess, "approve should succeed");
        goodies42Shop.grantAccess(address(student));
        bool buySuccess = student.tryBuy(address(goodies42Shop), 1, "42");
        require(buySuccess, "buy should succeed");
        require(goodies42.balanceOf(address(student)) == 100 * 10**18, "balance of student should be 100"); 
    }
    function test_studentWithAccessAndBadAnswer() public{
       goodies42.transfer(address(student), 100 * 10**18);
        goodies42Shop.setItemPrice(1, 50);
        bool approveSuccess = student.tryApprove(address(goodies42), address(goodies42Shop), 50 * 10**18);
        require(approveSuccess, "approve should succeed");
        goodies42Shop.grantAccess(address(student));
        require(goodies42Shop.userLotteryAccessCount(address(student)) == 1, "User have a lottery access.");
        bool buySuccess = student.tryBuy(address(goodies42Shop), 1, "21");
        require(buySuccess, "buy should succeed");
        require(goodies42.balanceOf(address(student)) == 50 * 10**18, "balance of student should be 50"); 
        require(goodies42Shop.userLotteryAccessCount(address(student)) == 0, "User does not have a lottery access.");
    }

    function test_studentCantSpendMoreMaxLotteryAccess() public{
       goodies42.transfer(address(student), 100 * 10**18);
        goodies42Shop.setItemPrice(1, 50);
        // first buy
        bool approveSuccess = student.tryApprove(address(goodies42), address(goodies42Shop), 50 * 10**18);
        require(approveSuccess, "approve should succeed");
        goodies42Shop.grantAccess(address(student));
        bool buySuccess = student.tryBuy(address(goodies42Shop), 1, "42");
        require(buySuccess, "buy should succeed");
        require(goodies42.balanceOf(address(student)) == 100 * 10**18, "balance of student should be 50"); 
        require(goodies42Shop.userAvailableLotteryAccessCount(address(student)) == 1, "User spend 1 lottery access.");
        // second buy
        approveSuccess = student.tryApprove(address(goodies42), address(goodies42Shop), 50 * 10**18);
        require(approveSuccess, "approve should succeed");
        goodies42Shop.grantAccess(address(student));
        buySuccess = student.tryBuy(address(goodies42Shop), 1, "42");
        require(buySuccess, "buy should succeed");
        require(goodies42.balanceOf(address(student)) == 100 * 10**18, "balance of student should be 50"); 
        require(goodies42Shop.userAvailableLotteryAccessCount(address(student)) == 2, "User spend 2 lottery access.");
        // third buy
        approveSuccess = student.tryApprove(address(goodies42), address(goodies42Shop), 50 * 10**18);
        require(approveSuccess, "approve should succeed");
        goodies42Shop.grantAccess(address(student));
        buySuccess = student.tryBuy(address(goodies42Shop), 1, "42");
        require(buySuccess, "buy should succeed");
        require(goodies42.balanceOf(address(student)) == 100 * 10**18, "balance of student should be 50"); 
        require(goodies42Shop.userAvailableLotteryAccessCount(address(student)) == 3, "User spend 3 lottery access.");
        // fourth
        approveSuccess = student.tryApprove(address(goodies42), address(goodies42Shop), 50 * 10**18);
        require(approveSuccess, "approve should succeed");
        (bool grantSuccess, ) = address(goodies42Shop).call(
            abi.encodeWithSignature("grantAccess(address)", address(student))
        );
        require(!grantSuccess, "grant access should fail");
        buySuccess = student.tryBuy(address(goodies42Shop), 1, "42");
        require(buySuccess, "buy should succeed");
        require(goodies42.balanceOf(address(student)) == 50 * 10**18, "balance of student should be 50"); 
        require(goodies42Shop.userAvailableLotteryAccessCount(address(student)) == 3, "User spend 3 lottery access.");
    }

}