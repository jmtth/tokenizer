// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Liberty } from "./Liberty.sol";

contract LibertyTest {
  Liberty liberty;

  function setUp() public {
    liberty = new Liberty(1000000);
  }

  function test_InitialValueIsZero() public view {
    require(liberty.initialSupply() == 1000000, "intialSupply should start at 1000000");
  }
}