// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SecureBank {
    // STORAGE
    mapping(address => uint256) private balances; // CHANGED: private now!
    address public owner;
    bool public paused; // Emergency stop
    
    // EVENTS (for logging)
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    
    // ERRORS (new way - gas efficient)
    error InsufficientBalance();
    error ContractPaused();
    error NotOwner();
    
    // MODIFIERS (reusable checks)
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _; // This means: "continue with the function"
    }
    
    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // PUBLIC: Can be called internally AND externally
    function deposit() public payable whenNotPaused {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    // EXTERNAL: Can ONLY be called from outside the contract
    function withdraw(uint256 amount) external whenNotPaused {
        // Using custom error instead of require (saves gas)
        if (balances[msg.sender] < amount) revert InsufficientBalance();
        
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }
    
    // PUBLIC: Can check balance
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    // INTERNAL: Only this contract or children can call
    function internalUpdate(uint256 newBalance) internal {
        balances[msg.sender] = newBalance;
    }
    
    // ONLYOWNER: Admin functions
    function emergencyPause() public onlyOwner {
        paused = true;
    }
    
    function emergencyWithdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}