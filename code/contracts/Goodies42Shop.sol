// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IGoodies42ERC20.sol";

contract Goodies42Shop {
    IGoodies42ERC20 public token;
    address public owner;
    address public pendingOwner;
    uint256 public constant MAX_LOTTERY_ACCESS = 3;
    mapping(uint256 => uint256) public itemPrice;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    /**
     * @dev userAccessCount tracks the number of free accesses (LotteryAccess) each student has.
     */
    mapping(address => uint256) public userLotteryAccessCount;
    mapping(address => uint256) public userAvailableLotteryAccessCount;
    
    // Hash de la réponse attendue pour le bonus LotteryAccess
    bytes32 public constant HASH_ANSWER = 0xccb1f717aa77602faf03a594761a36956b1c4cf44c6b336d1db57da799b331b8;

    event ItemPurchased(address indexed student, uint256 indexed itemId, uint256 pricePaid, bool wasFree);
    event ItemPriceUpdated(uint256 indexed itemId, uint256 price);
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed pendingOwner);
    event TokensWithdrawn(address indexed to, uint256 amount);

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IGoodies42ERC20(_tokenAddress);
        owner = msg.sender;
    }

    /**
     * @dev Allows the current owner to transfer ownership to a new owner.
     * The new owner must call acceptOwnership to complete the transfer.
     * This two-step process prevents accidental transfers and allows the new owner to prepare for ownership.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    /**
     * @dev Completes the ownership transfer by the pending owner accepting ownership.
     * It checks that the caller is the pending owner and then updates the owner state.
     * It emits an OwnerChanged event on successful transfer.
     */
    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "Not pending owner");
        address previousOwner = owner;
        owner = pendingOwner;
        pendingOwner = address(0);
        emit OwnerChanged(previousOwner, owner);
    }

    /**
     * @dev The Staff can grant free access (LotteryAccess) 
     * to students who has 125% + outstanding
     * the student can has 3 accesses max
     */
    function grantAccess(address student) external onlyOwner {
        require(student != address(0), "Invalid student");
        require(userAvailableLotteryAccessCount[student] < MAX_LOTTERY_ACCESS, "LotteryAccess max reached");
        userLotteryAccessCount[student] += 1;
        userAvailableLotteryAccessCount[student] += 1;
    }

    /**
     * @dev Sets the price of an item in tokens. Only the owner can set prices.
     */
    function setItemPrice(uint256 itemId, uint256 priceInTokens) external onlyOwner {
        require(priceInTokens > 0, "Invalid price");
        uint256 price = priceInTokens * 10**18;
        itemPrice[itemId] = price;
        emit ItemPriceUpdated(itemId, price);
    }

    /**
     * @dev Logic for purchasing an item. 
     * The student can either use a free access (if they have one and answer correctly) or pay with tokens.
     */
    function buy(uint256 itemId, string memory _answer) public {
        uint256 price = itemPrice[itemId];
        require(price > 0, "Item not configured");
        bool isCorrect = (keccak256(abi.encodePacked(_answer)) == HASH_ANSWER);

        if (userLotteryAccessCount[msg.sender] > 0 && isCorrect) {
            // USECASE FREE GOODIES ACCESS
            userLotteryAccessCount[msg.sender] -= 1;
            emit ItemPurchased(msg.sender, itemId, 0, true);
        } else {
            // USECASE PAID ACCESS
            // the student must pay the price in tokens to buy the item
            // he must have approved the shop to spend the tokens beforehand
            bool transferred = token.transferFrom(msg.sender, address(this), price);
            require(transferred, "Payment transfer failed");
            
            // If the student had an access but got the answer wrong, 
            // we consume the access anyway
            if (userLotteryAccessCount[msg.sender] > 0) {
                userLotteryAccessCount[msg.sender] -= 1;
            }
            emit ItemPurchased(msg.sender, itemId, price, false);
        }
    }

    // Helper function to check the shop's token balance
    function shopTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // the owner can withdraw tokens from the shop to a specified address
    function withdrawTokens(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid recipient");
        bool transferred = token.transfer(to, amount);
        require(transferred, "Withdraw transfer failed");
        emit TokensWithdrawn(to, amount);
    }

}
