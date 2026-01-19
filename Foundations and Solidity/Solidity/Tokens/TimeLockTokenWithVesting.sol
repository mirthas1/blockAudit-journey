// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract TimeLockToken {
    // === STORAGE === (All concepts we know)
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // NEW: Time-lock tracking
    mapping(address => LockedBalance[]) public lockedBalances;
    mapping(address => uint256) public totalLocked;
    
    // Access control
    address public owner;
    mapping(address => bool) public lockManagers;
    
    // === STRUCTS === (We know structs)
    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }
    
    // === EVENTS ===
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensUnlocked(address indexed user, uint256 amount);
    event LockManagerUpdated(address indexed account, bool status);
    
    // === ERRORS ===
    error InsufficientBalance();
    error InsufficientUnlockedBalance();
    error ZeroAddress();
    error NotOwner();
    error NotLockManager();
    error LockPeriodNotEnded();
    
    // === MODIFIERS ===
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    modifier onlyLockManager() {
        if (!lockManagers[msg.sender]) revert NotLockManager();
        _;
    }
    
    modifier validAddress(address addr) {
        if (addr == address(0)) revert ZeroAddress();
        _;
    }
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**_decimals;
        
        owner = msg.sender;
        lockManagers[msg.sender] = true;
        
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    // === CORE ERC20 FUNCTIONS ===
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    // MODIFIED: Check unlocked balance before transfer
    function transfer(address to, uint256 amount) public returns (bool) {
        require(getUnlockedBalance(msg.sender) >= amount, "Insufficient unlocked balance");
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner0, address spender) public view returns (uint256) {
        return _allowances[owner0][spender];
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    // MODIFIED: Check unlocked balance before transferFrom
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(getUnlockedBalance(from) >= amount, "Insufficient unlocked balance");
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    // === TIME-LOCK FUNCTIONS ===
    
    // Lock tokens for a specific duration
    function lockTokens(address user, uint256 amount, uint256 unlockTime) 
        public 
        onlyLockManager 
        validAddress(user) 
    {
        require(amount > 0, "Amount must be positive");
        require(unlockTime > block.timestamp, "Unlock time must be in future");
        require(_balances[user] >= amount, "Insufficient balance");
        
        // Create new lock
        lockedBalances[user].push(LockedBalance({
            amount: amount,
            unlockTime: unlockTime
        }));
        
        totalLocked[user] += amount;
        
        emit TokensLocked(user, amount, unlockTime);
    }
    
    // Unlock tokens that have passed their lock period
    function unlockTokens(address user) public {
        uint256 unlockedAmount = 0;
        
        // Check all locks for this user
        for (uint256 i = 0; i < lockedBalances[user].length; i++) {
            if (lockedBalances[user][i].unlockTime <= block.timestamp && lockedBalances[user][i].amount > 0) {
                unlockedAmount += lockedBalances[user][i].amount;
                lockedBalances[user][i].amount = 0; // Mark as unlocked
            }
        }
        
        if (unlockedAmount > 0) {
            totalLocked[user] -= unlockedAmount;
            emit TokensUnlocked(user, unlockedAmount);
        }
    }
    
    // View function to check unlocked balance
    function getUnlockedBalance(address user) public view returns (uint256) {
        return _balances[user] - totalLocked[user];
    }
    
    // View function to get lock details
    function getLockDetails(address user) public view returns (LockedBalance[] memory) {
        return lockedBalances[user];
    }
    
    // === ACCESS CONTROL ===
    function addLockManager(address account) public onlyOwner validAddress(account) {
        lockManagers[account] = true;
        emit LockManagerUpdated(account, true);
    }
    
    function removeLockManager(address account) public onlyOwner validAddress(account) {
        lockManagers[account] = false;
        emit LockManagerUpdated(account, false);
    }
    
    // === INTERNAL FUNCTIONS ===
    function _transfer(address from, address to, uint256 amount) internal validAddress(to) {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient balance");
        
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }
    
    function _approve(address owner1, address spender, uint256 amount) internal validAddress(spender) {
        _allowances[owner1][spender] = amount;
        emit Approval(owner1, spender, amount);
    }
    
    function _spendAllowance(address owner2, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner2, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            _approve(owner2, spender, currentAllowance - amount);
        }
    }
}