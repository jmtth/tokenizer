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

    /**
     * @dev transfer function that checks for sufficient balance 
     * and prevents transfers to the zero address.
     * It emits a Transfer event on success.
     * I use require + string messages for better error handling and debugging, 
     * in production it is better to use ERC20 errors like for better gas efficiency
     * if (recipient == address(0)) revert ERC20InvalidReceiver(address(0));
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /** @dev approve function that sets the allowance for a spender and emits an Approval event.
     * It checks that the spender is not the zero address to prevent potential issues with approvals.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "Invalid spender");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** 
     * @dev transferFrom function that transfers tokens from a sender to a recipient
     * checking for sufficient balance and allowance.
     * It emits Transfer and Approval events on success.
     */
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

    /** 
     * @dev internal mint function that creates new tokens and assigns them to a recipient.
     * It updates the total supply and emits a Transfer event from the zero address.
     * The public mint function is owner-restricted and allows minting whole tokens 
     * by multiplying the amount with 10^decimals.
     */
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Invalid recipient");
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function mint(address to, uint256 amount) external override onlyOwner {
        _mint(to, amount * 10 ** uint256(decimals));
    }

    /**
     * @dev Initiates ownership transfer by setting a pending owner.
     * The pending owner must call acceptOwnership to complete the transfer.
     * This two-step process prevents accidental transfers and allows the new owner to prepare for ownership.
     * It emits an OwnershipTransferStarted event when the transfer is initiated.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(Goodies42owner, newOwner);
    }

    /**
     * @dev Completes the ownership transfer by the pending owner accepting ownership.
     * It checks that the caller is the pending owner and then updates the owner state.
     * It emits an OwnerChanged event on successful transfer.
     */
    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "Not pending owner");
        address previousOwner = Goodies42owner;
        Goodies42owner = pendingOwner;
        pendingOwner = address(0);
        emit OwnerChanged(previousOwner, Goodies42owner);
    }

}
