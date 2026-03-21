// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IGoodies42ERC20.sol";

contract GoodiesShop {
    IGoodies42ERC20 public token;
    address public owner;
    uint256 public constant MAX_LOTTERY_ACCESS = 3;
    mapping(uint256 => uint256) public itemPrice;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    // Mapping pour suivre les "Accès Question" gagnés à 125% + outstanding
    mapping(address => uint256) public userAccessCount;
    
    // Hash de la réponse attendue pour le bonus LotteryAccess
    bytes32 private constant ANSWER_HASH = 0xccb1f717aa77602faf03a594761a36956b1c4cf44c6b336d1db57da799b331b8;

    event ItemPurchased(address indexed student, uint256 indexed itemId, uint256 pricePaid, bool wasFree);
    event ItemPriceUpdated(uint256 indexed itemId, uint256 price);
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event TokensWithdrawn(address indexed to, uint256 amount);

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IGoodies42ERC20(_tokenAddress);
        owner = msg.sender;
    }
    /**
     * @dev permet au Shop Owner de transférer la propriété du shop à une nouvelle adresse.
      * Utile pour la maintenance ou le transfert de contrôle du shop.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnerChanged(previousOwner, newOwner);
    }

    /**
     * @dev Le Staff crédite un accès suite à un projet à 125% + outstanding.
     */
    function grantAccess(address student) external onlyOwner {
        require(student != address(0), "Invalid student");
        require(userAccessCount[student] < MAX_LOTTERY_ACCESS, "LotteryAccess max reached");
        userAccessCount[student] += 1;
    }

    /**
     * @dev Définit le prix d'un item en tokens complets (base units calculées dans le contrat).
     */
    function setItemPrice(uint256 itemId, uint256 priceInTokens) external onlyOwner {
        require(priceInTokens > 0, "Invalid price");
        uint256 price = priceInTokens * 10**18;
        itemPrice[itemId] = price;
        emit ItemPriceUpdated(itemId, price);
    }

    /**
     * @dev Logique d'achat d'un item via prix on-chain.
     */
    function buy(uint256 itemId, string memory _answer) public {
        uint256 price = itemPrice[itemId];
        require(price > 0, "Item not configured");
        bool isCorrect = (keccak256(abi.encodePacked(_answer)) == ANSWER_HASH);

        if (userAccessCount[msg.sender] > 0 && isCorrect) {
            // CAS RÉUSSI : On consomme l'accès, mais on ne touche pas aux tokens
            userAccessCount[msg.sender] -= 1;
            emit ItemPurchased(msg.sender, itemId, 0, true);
        } else {
            // CAS ÉCHEC OU PAS D'ACCÈS : Le shop encaisse les tokens de l'étudiant
            // Note: l'étudiant doit avoir fait "approve" sur le contrat Token avant.
            bool transferred = token.transferFrom(msg.sender, address(this), price);
            require(transferred, "Payment transfer failed");
            
            // Si l'étudiant avait un accès mais a raté la réponse, on consomme l'accès quand même
            if (userAccessCount[msg.sender] > 0) {
                userAccessCount[msg.sender] -= 1;
            }
            emit ItemPurchased(msg.sender, itemId, price, false);
        }
    }

    function shopTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function withdrawTokens(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid recipient");
        bool transferred = token.transfer(to, amount);
        require(transferred, "Withdraw transfer failed");
        emit TokensWithdrawn(to, amount);
    }

}
