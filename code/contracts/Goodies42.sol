// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import "./IGoodies42ERC20.sol";

 // @name Goodies42
 // A simple ERC20 token.
 // includes an owner-controlled minting function.
 // The ERC20 standard typically uses 'decimals' to represent token divisibility.
 // To mint 'initialSupply' whole tokens, we multiply by 10 raised to the power of 'decimals()'.
 // Example: If initialSupply is 1000 and decimals() is 18, we mint 1000 * (10**18) base units.
 //
 // ERC20 events (hérités de IERC20 / IERC20Metadata, donc non redéclarés ici):
 // event Transfer(address indexed from, address indexed to, uint256 value);
 // event Approval(address indexed owner, address indexed spender, uint256 value);

contract Goodies42 is IGoodies42ERC20 {
    address public Goodies42owner;
    address public pendingOwner;
    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    string public constant override name = "Goodies42";
    string public constant override symbol = "GDS42";
    uint8 public constant override decimals = 18;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed pendingOwner);

    modifier onlyOwner() {
        require(msg.sender == Goodies42owner, "Only owner");
        _;
    }

    constructor() {
        Goodies42owner = msg.sender;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "Invalid spender");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "Invalid recipient");
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        emit Approval(sender, msg.sender, allowance[sender][msg.sender]);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Invalid recipient");
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "Invalid sender");
        require(balanceOf[from] >= amount, "Insufficient balance to burn");
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external override onlyOwner {
        _mint(to, amount * 10 ** uint256(decimals));
    }

    function burn(address from, uint256 amount) external override onlyOwner {
        _burn(from, amount * 10 ** uint256(decimals));
    }

    function burnFrom(address from, uint256 amount) external override {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        emit Approval(from, msg.sender, allowance[from][msg.sender]);
        _burn(from, amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(Goodies42owner, newOwner);
    }

    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "Not pending owner");
        address previousOwner = Goodies42owner;
        Goodies42owner = pendingOwner;
        pendingOwner = address(0);
        emit OwnerChanged(previousOwner, Goodies42owner);
    }

}
