// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import "./IERC20.sol";

 // @name Liberty
 // A simple ERC20 token.
 // includes an owner-controlled minting function.
 // The ERC20 standard typically uses 'decimals' to represent token divisibility.
 // To mint 'initialSupply' whole tokens, we multiply by 10 raised to the power of 'decimals()'.
 // Example: If initialSupply is 1000 and decimals() is 18, we mint 1000 * (10**18) base units.

contract Liberty is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address payable public Libertyowner;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        Libertyowner = payable(msg.sender);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
     function _mint(address to, uint256 amount) internal {
        require(msg.sender == Libertyowner, "Only the owner can mint tokens");
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(msg.sender == Libertyowner, "Only the owner can burn tokens");
        require(balanceOf[from] >= amount, "Insufficient balance to burn");
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == Libertyowner, "Only the owner can mint tokens");
        _mint(to, amount * 10 ** uint256(decimals));
    }

    function burn(address from, uint256 amount) external {
        require(msg.sender == Libertyowner, "Only the owner can burn tokens");
        _burn(from, amount * 10 ** uint256(decimals));
    }


}
