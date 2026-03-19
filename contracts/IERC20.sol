// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IERC20 {
    // direct transfer of tokens from the caller to a recipient
    function transfer(address recipient, uint256 amount) external returns (bool);
    // approve a spender to transfer up to a certain amount of tokens on behalf of the caller
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    // check how much a spender is allowed to transfer on behalf of an owner
    function allowance(address owner, address spender) external view returns (uint256);
    // transfer tokens from one address to another using an allowance
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
}