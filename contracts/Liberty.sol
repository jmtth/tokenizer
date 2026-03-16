// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

 // @name Liberty
 // A simple ERC20 token with a fixed initial supply minted to the deployer.
 // includes an owner-controlled minting function.
 //  @param initialSupply The total number of tokens to create initially (e.g., 1000000 for one million tokens).
 //        The deployer of the contract will receive all initial tokens.
 // ERC20(name_, symbol_): Calls the constructor of the parent ERC20 contract, setting the token's name and symbol.
 // Ownable(msg.sender): Sets the address deploying the contract
 // The ERC20 standard typically uses 'decimals' to represent token divisibility.
 // OpenZeppelin's ERC20 contract defaults to 18 decimals.
 // To mint 'initialSupply' whole tokens, we multiply by 10 raised to the power of 'decimals()'.
 // Example: If initialSupply is 1000 and decimals() is 18, we mint 1000 * (10**18) base units.
contract Liberty is ERC20, Ownable {
    constructor( uint256 initialSupply) ERC20("Liberty", "LBY") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }

}
