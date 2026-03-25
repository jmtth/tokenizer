// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import "./IGoodies42ERC20.sol";


contract Goodies42Management {
    address[] public managers;
    mapping(address => bool) public isManager;
    uint256 public numConfirmationsRequired;
}