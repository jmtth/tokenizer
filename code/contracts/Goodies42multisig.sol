// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


contract Goodies42Management {
    // List of manager
    address[] public managers;
    // Direct access of manager for better efficiency / Gas
    mapping(address => bool) public isManager;
    uint256 public numSignaturesRequired;
    uint256 public activeManagerCount;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numSignatures;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isSigned;

    event ManagerAdded(address indexed manager);
    event ManagerRemoved(address indexed manager);
    event TransactionSubmitted(address indexed manager, uint256 indexed txIndex, address indexed to, uint256 value, bytes data);
    event TransactionSigned(uint256 indexed txIndex, address indexed manager);
    event TransactionExecuted(uint256 indexed txIndex);
    event TransactionUnsigned(uint256 indexed txIndex, address indexed manager);
    event Deposit(address indexed sender, uint256 amount, uint256 balance);

    /**
      * @dev Four Modifier to manage access control and transaction state:
      * - onlyManager: Restricts function access to managers only.
      * - txExists: Ensures the transaction index is valid.
      * - notExecuted: Ensures the transaction has not already been executed.
      * - notSigned: Ensures the manager has not already signed the transaction.
      * - onlyGoodies42Management: Ensures that internal methods can only be executed through the multisig flow.
      * _; is used to insert the body of the function that uses the modifier .
      * at the appropriate place in the execution flow.
      */
    modifier onlyManager() {
        require(isManager[msg.sender], "Only managers");
        _;   
    }
    modifier onlyGoodies42Management() {
        require(msg.sender == address(this), "Only multisig");
        _;
    }
    modifier txExists(uint256 txIndex) {
        require(txIndex < transactions.length, "Transaction does not exist");
        _;
    }
    modifier notExecuted(uint256 txIndex) {
        require(!transactions[txIndex].executed, "Transaction already executed");
        _;  
    }
    modifier notSigned(uint256 txIndex) {
        require(!isSigned[txIndex][msg.sender], "Transaction already signed");
        _;
    }

    constructor(address[] memory _managers, uint256 _numSignaturesRequired) {
        require(_managers.length > 0, "At least one manager required");
        require(_numSignaturesRequired > 0 && _numSignaturesRequired <= _managers.length, "Invalid number of signatures required");

        for (uint256 i = 0; i < _managers.length; i++) {
            address manager = _managers[i];
            activeManagerCount = _managers.length;
            require(manager != address(0), "Invalid manager address");
            require(!isManager[manager], "Manager not unique");

            isManager[manager] = true;
            managers.push(manager);
            emit ManagerAdded(manager);
        }
        numSignaturesRequired = _numSignaturesRequired;
    }

    /**
      * @dev Submits a new transaction for approval.
      * @param _to The address of the recipient.
      * @param _value The amount of ETH to transfer. Only 0 for token transactions
      * @param _data The calldata for the transaction.
      * it is the method of a smart contract like function mint(address,uint256)
      * but encode in hexadecimal format 0x8a9255ab0000...
      * we can use calldata because we don't change the method
      * @notice txIndex the index of a transaction start from 0.
     */
    function submitTransaction(address _to, uint256 _value, bytes calldata _data)  public onlyManager {
        require(_to != address(0), "Invalid recipient");
        uint256 txIndex = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numSignatures: 0
        }));
        emit TransactionSubmitted(msg.sender, txIndex, _to, _value, _data);  
    }

    /**
      * @dev Signs a transaction.
      * The manager must not have already signed the transaction, 
      * and the transaction must not have been executed.
      * @param txIndex The index of the transaction to sign.
      * @notice storage is used to update the transaction in place, 
      * which is more efficient than memory for this use case.
      * it is a pointer to the transaction struct in the transactions array,
      * so any changes to transaction will update the struct in the array directly.
     */
    function signTransaction(uint256 txIndex) public onlyManager txExists(txIndex) notExecuted(txIndex) notSigned(txIndex) {
        Transaction storage transaction = transactions[txIndex];
        transaction.numSignatures += 1;
        isSigned[txIndex][msg.sender] = true;   
        emit TransactionSigned(txIndex, msg.sender);
    }

    /**
      * @dev excute a transaction, a smart contract method 
      * @param txIndex The index of the transaction to execute.
      * The transaction must have enough signatures and must not have been executed.
      * The call method is used to execute the transaction,
      * which allows for sending ETH and calling functions on other contracts.
      */
    function executeTransaction(uint256 txIndex) public onlyManager txExists(txIndex) notExecuted(txIndex) {
        Transaction storage transaction = transactions[txIndex];
        require(transaction.numSignatures >= numSignaturesRequired, "Not enough signatures");

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transaction execution failed");
        emit TransactionExecuted(txIndex);
    }

    function unsignTransaction(uint256 txIndex) public onlyManager txExists(txIndex) notExecuted(txIndex) {
        require(isSigned[txIndex][msg.sender], "Transaction not signed by this manager");
        Transaction storage transaction = transactions[txIndex];
        transaction.numSignatures -= 1;
        isSigned[txIndex][msg.sender] = false;   
        emit TransactionUnsigned(txIndex, msg.sender);
    }

    function addManager(address newManager) public onlyGoodies42Management {
        require(newManager != address(0), "Invalid manager address");
        require(!isManager[newManager], "Manager already exists");

        isManager[newManager] = true;
        activeManagerCount +=1;
        managers.push(newManager);
        emit ManagerAdded(newManager);
    }

    function removeManager(address oldManager) public onlyGoodies42Management {
        require(isManager[oldManager], "Manager does not exist");
        require(activeManagerCount - 1 >= numSignaturesRequired, "Cannot remove manager, not enough managers left");
        require(oldManager != msg.sender, "Manager cannot remove themselves");

        isManager[oldManager] = false;
        for (uint256 i = 0; i < managers.length; i++) {
            if (managers[i] == oldManager) {
                managers[i] = address(0);
                activeManagerCount -=1;
                break;
            }
        }
        emit ManagerRemoved(oldManager);
    }
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 txIndex) external view 
        returns (
            address to,
                uint256 value,
                bytes memory data,
                bool executed,
                uint256 numSignatures
            ) {
        Transaction storage transaction = transactions[txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numSignatures
        );
    }
}