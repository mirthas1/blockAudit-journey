// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultiSigWallet {

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 conformations;
    }

    Transaction[] public transcations;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    event DEposit(address indexed sender, uint256 amount);
    event SubmitTransaction(uint256 indexed txID, address indexed to, uint256 value);
    event ConfirmTransaction(address indexed owner, uint256 indexed txId);
    event ExecuteTransaction(uint256 indexed ixId);

    constructor(address[] memory _owners, uint256 _required) {
        owners = _owners;
        required = _required;

        for (uint i =0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }

    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not Owner");
        _;
    }

    function SubmitTransaction1 (address to, uint256 value, bytes memory data)
    public onlyOwner returns (uint256)
    {
        uint256 txid = transcations.length;
        transcations.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 0
        }));
        emit SubmitTransaction(txid, to, value);
        return txid;
    }
    
    function confirmTransaction(uint256 txid) public onlyOwner {
        require(txid < transcations.length, "Invalid tx ID");
        require(!transcations[txid].executed, "Already executed");
        require(!confirmations[txid][msg.sender], "Already confirmed");
        confirmations[txid][msg.sender] = true;
       Transaction[txid].confirmations += 1;
        emit ConfirmTransaction(msg.sender, txid);
    }

    function getConfirmation(uint256 txID) public view returns (address[] memory) {
        address[] memory confirmationsList = new address[](owners.length);
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[txID][owners[i]]) {
                confirmationsList[count] = owners[i];
                count += 1;
            }
        }
        return confirmationsList;
    }

    receive() external payable { 
        emit DEposit(msg.sendr, msg.value);
    }
    }
