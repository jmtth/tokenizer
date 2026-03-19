// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Liberty } from "./Liberty.sol";

contract NonOwnerMinter {
  function tryMint(address token, address to, uint256 amount) external returns (bool) {
    (bool success, ) = token.call(
      abi.encodeWithSignature("mint(address,uint256)", to, amount)
    );
    return success;
  }
}

contract LibertyTest {
  Liberty liberty;
  NonOwnerMinter nonOwner;

  address recipient = address(0xBEEF);

  function setUp() public {
    liberty = new Liberty("Liberty", "LIB", 18);
    nonOwner = new NonOwnerMinter();
  }

  // Vérifie que le contrat est initialisé avec les bonnes métadonnées et un supply à 0.
  function test_InitializesWithExpectedValues() public view {
    require(keccak256(bytes(liberty.name())) == keccak256(bytes("Liberty")), "invalid name");
    require(keccak256(bytes(liberty.symbol())) == keccak256(bytes("LIB")), "invalid symbol");
    require(liberty.decimals() == 18, "invalid decimals");
    require(liberty.Libertyowner() == address(this), "invalid owner");
    require(liberty.totalSupply() == 0, "total supply should start at 0");
  }

  // Vérifie que seul le owner peut mint et que le mint crédite le bon montant (avec decimals).
  function test_OnlyOwnerCanMint() public {
    bool success = nonOwner.tryMint(address(liberty), recipient, 1);
    require(!success, "non-owner mint should fail");

    liberty.mint(address(this), 1);
    require(liberty.balanceOf(address(this)) == 1e18, "owner mint should succeed");
  }

  // Vérifie qu'on peut transférer jusqu'au solde max, mais pas au-delà.
  function test_TransferCannotExceedBalance() public {
    liberty.mint(address(this), 100);

    bool transferSuccess = liberty.transfer(recipient, 100 * 1e18);
    require(transferSuccess, "transfer at max balance should succeed");
    require(liberty.balanceOf(address(this)) == 0, "owner balance should be 0 after transfer");
    require(liberty.balanceOf(recipient) == 100 * 1e18, "recipient should receive transferred tokens");

    (bool shouldFail, ) = address(liberty).call(
      abi.encodeWithSignature("transfer(address,uint256)", recipient, 1)
    );
    require(!shouldFail, "transfer above balance should fail");
  }
}