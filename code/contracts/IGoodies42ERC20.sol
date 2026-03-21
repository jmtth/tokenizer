// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IGoodies42ERC20 is IERC20Metadata {
    function mint(address to, uint256 amount) external;
}