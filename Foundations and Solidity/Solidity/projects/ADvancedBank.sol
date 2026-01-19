// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AdvancedBank {
    // Storage: Core data
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _frozenAccounts;
    
    address private _owner;
    bool private _paused;
    uint256 private _totalSupply;
    uint256 private _maxWithdrawalLimit;
    
    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Errors
    error InsufficientBalance();
    error AccountIsFrozen();
    error ExceedsWithdrawalLimit();
    error ContractPaused();
    error NotOwner();
    error ZeroAddress();
    
    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != _owner) revert NotOwner();
        _;
    }
    
    modifier whenNotPaused() {
        if (_paused) revert ContractPaused();
        _;
    }
    
    modifier whenNotFrozen(address account) {
        if (_frozenAccounts[account]) revert AccountIsFrozen();
        _;
    }
    
    constructor() {
        _owner = msg.sender;
        _maxWithdrawalLimit = 10 ether;
    }
    
    // Core banking functions
    function deposit() public payable whenNotPaused whenNotFrozen(msg.sender) {
        _balances[msg.sender] += msg.value;
        _totalSupply += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    function withdraw(uint256 amount) public whenNotPaused whenNotFrozen(msg.sender) {
        if (amount > _maxWithdrawalLimit) revert ExceedsWithdrawalLimit();
        if (_balances[msg.sender] < amount) revert InsufficientBalance();
        
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(msg.sender, amount);
    }
    
    // Allowance system (like ERC20)
    function approve(address spender, uint256 amount) public whenNotPaused returns (bool) {
        if (spender == address(0)) revert ZeroAddress();
        _allowances[msg.sender][spender] = amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public whenNotPaused whenNotFrozen(from) returns (bool) {
        if (_balances[from] < amount) revert InsufficientBalance();
        if (_allowances[from][msg.sender] < amount) revert InsufficientBalance();
        
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        
        return true;
    }
    
    // Admin functions
    function freezeAccount(address account) public onlyOwner {
        _frozenAccounts[account] = true;
        emit AccountFrozen(account);
    }
    
    function unfreezeAccount(address account) public onlyOwner {
        _frozenAccounts[account] = false;
        emit AccountUnfrozen(account);
    }
    
    function setWithdrawalLimit(uint256 newLimit) public onlyOwner {
        _maxWithdrawalLimit = newLimit;
    }
    
    function emergencyPause() public onlyOwner {
        _paused = true;
    }
    
    function emergencyWithdraw() public onlyOwner {
        _paused = false; // Unpause to allow transfer
        payable(_owner).transfer(address(this).balance);
    }
    
    // View functions
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function isFrozen(address account) public view returns (bool) {
        return _frozenAccounts[account];
    }
    
    function getTotalSupply() public view returns (uint256) {
        return _totalSupply;
    }
}