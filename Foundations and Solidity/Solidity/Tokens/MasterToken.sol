// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MasterToken {
    // === STORAGE ===
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public maxSupply;
    
    // Core mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Fee system
    address public feeCollector;
    uint256 public transferFee; // 100 = 1%
    uint256 public maxFee = 1000; // 10% maximum
    
    // Mint/Burn system
    address public owner;
    mapping(address => bool) public minters;
    mapping(address => bool) public burners;
    
    // Time-lock system
    mapping(address => LockedBalance[]) public lockedBalances;
    mapping(address => uint256) public totalLocked;
    
    // Blacklist system
    mapping(address => bool) public blacklisted;
    
    // === STRUCTS ===
    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }
    
    // === EVENTS ===
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensUnlocked(address indexed user, uint256 amount);
    event AddressBlacklisted(address indexed account);
    event AddressWhitelisted(address indexed account);
    event FeeUpdated(uint256 newFee);
    event FeeCollectorUpdated(address newCollector);
    
    // === ERRORS ===
    error InsufficientBalance();
    error InsufficientUnlockedBalance();
    error ZeroAddress();
    error NotOwner();
    error NotMinter();
    error NotBurner();
    error ExceedsMaxSupply();
    error addressBlacklisted();
    error InvalidFee();
    
    // === MODIFIERS ===
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    modifier onlyMinter() {
        if (!minters[msg.sender]) revert NotMinter();
        _;
    }
    
    modifier onlyBurner() {
        if (!burners[msg.sender]) revert NotBurner();
        _;
    }
    
    modifier notBlacklisted(address account) {
        if (blacklisted[account]) revert addressBlacklisted();
        _;
    }
    
    modifier validAddress(address addr) {
        if (addr == address(0)) revert ZeroAddress();
        _;
    }
    
    // === CONSTRUCTOR ===
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        uint256 _maxSupply,
        address _feeCollector,
        uint256 _transferFee
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        maxSupply = _maxSupply * 10**_decimals;
        
        owner = msg.sender;
        feeCollector = _feeCollector;
        
        // Set up roles
        minters[msg.sender] = true;
        burners[msg.sender] = true;
        
        // Validate and set fee
        if (_transferFee > maxFee) revert InvalidFee();
        transferFee = _transferFee;
        
        // Mint initial supply
        _mint(msg.sender, _initialSupply * 10**_decimals);
    }
    
    // === CORE ERC20 WITH FEE ===
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) 
        public 
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool) 
    {
        require(getUnlockedBalance(msg.sender) >= amount, "Insufficient unlocked balance");
        _transferWithFee(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner9, address spender) public view returns (uint256) {
        return _allowances[owner9][spender];
    }
    
    function approve(address spender, uint256 amount) 
        public 
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool) 
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) 
        public 
        notBlacklisted(from)
        notBlacklisted(to)
        notBlacklisted(msg.sender)
        returns (bool) 
    {
        require(getUnlockedBalance(from) >= amount, "Insufficient unlocked balance");
        _spendAllowance(from, msg.sender, amount);
        _transferWithFee(from, to, amount);
        return true;
    }
    
    // === MINTING SYSTEM ===
    function mint(address to, uint256 amount) 
        public 
        onlyMinter
        notBlacklisted(to)
    {
        _mint(to, amount);
    }
    
    function _mint(address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        
        uint256 newTotalSupply = totalSupply + amount;
        if (newTotalSupply > maxSupply) revert ExceedsMaxSupply();
        
        totalSupply = newTotalSupply;
        _balances[to] += amount;
        
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }
    
    // === BURNING SYSTEM ===
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    function burnFrom(address from, uint256 amount) 
        public 
        onlyBurner
        notBlacklisted(from)
    {
        _spendAllowance(from, msg.sender, amount);
        _burn(from, amount);
    }
    
    function _burn(address from, uint256 amount) internal {
        if (from == address(0)) revert ZeroAddress();
        
        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) revert InsufficientBalance();
        
        _balances[from] = fromBalance - amount;
        totalSupply -= amount;
        
        emit Burn(from, amount);
        emit Transfer(from, address(0), amount);
    }
    
    // === FEE SYSTEM ===
    function _transferWithFee(address from, address to, uint256 amount) internal {
        if (from == address(0)) revert ZeroAddress();
        if (to == address(0)) revert ZeroAddress();
        
        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) revert InsufficientBalance();
        
        // Calculate fee
        uint256 feeAmount = (amount * transferFee) / 10000;
        uint256 netAmount = amount - feeAmount;
        
        // Update balances
        _balances[from] = fromBalance - amount;
        _balances[to] += netAmount;
        
        // Collect fee
        if (feeAmount > 0) {
            _balances[feeCollector] += feeAmount;
        }
        
        emit Transfer(from, to, netAmount);
        if (feeAmount > 0) {
            emit Transfer(from, feeCollector, feeAmount);
        }
    }
    
    // === TIME-LOCK SYSTEM ===
    function lockTokens(address user, uint256 amount, uint256 unlockTime) 
        public 
        onlyOwner 
        notBlacklisted(user)
    {
        require(amount > 0, "Amount must be positive");
        require(unlockTime > block.timestamp, "Unlock time must be in future");
        require(_balances[user] >= amount, "Insufficient balance");
        
        lockedBalances[user].push(LockedBalance({
            amount: amount,
            unlockTime: unlockTime
        }));
        
        totalLocked[user] += amount;
        emit TokensLocked(user, amount, unlockTime);
    }
    
    function unlockTokens(address user) public {
        uint256 unlockedAmount = 0;
        
        for (uint256 i = 0; i < lockedBalances[user].length; i++) {
            if (lockedBalances[user][i].unlockTime <= block.timestamp && 
                lockedBalances[user][i].amount > 0) {
                unlockedAmount += lockedBalances[user][i].amount;
                lockedBalances[user][i].amount = 0;
            }
        }
        
        if (unlockedAmount > 0) {
            totalLocked[user] -= unlockedAmount;
            emit TokensUnlocked(user, unlockedAmount);
        }
    }
    
    function getUnlockedBalance(address user) public view returns (uint256) {
        return _balances[user] - totalLocked[user];
    }
    
    function getLockDetails(address user) public view returns (LockedBalance[] memory) {
        return lockedBalances[user];
    }
    
    // === BLACKLIST SYSTEM ===
    function blacklistAddress(address account) public onlyOwner {
        blacklisted[account] = true;
        emit AddressBlacklisted(account);
    }
    
    function whitelistAddress(address account) public onlyOwner {
        blacklisted[account] = false;
        emit AddressWhitelisted(account);
    }
    
    // === FEE MANAGEMENT ===
    function updateFee(uint256 newFee) public onlyOwner {
        if (newFee > maxFee) revert InvalidFee();
        transferFee = newFee;
        emit FeeUpdated(newFee);
    }
    
    function updateFeeCollector(address newCollector) 
        public 
        onlyOwner 
        validAddress(newCollector)
    {
        feeCollector = newCollector;
        emit FeeCollectorUpdated(newCollector);
    }
    
    // === ROLE MANAGEMENT ===
    function addMinter(address account) public onlyOwner validAddress(account) {
        minters[account] = true;
    }
    
    function removeMinter(address account) public onlyOwner validAddress(account) {
        minters[account] = false;
    }
    
    function addBurner(address account) public onlyOwner validAddress(account) {
        burners[account] = true;
    }
    
    function removeBurner(address account) public onlyOwner validAddress(account) {
        burners[account] = false;
    }
    
    // === INTERNAL FUNCTIONS ===
    function _approve(address ownerr, address spender, uint256 amount) internal {
        _allowances[ownerr][spender] = amount;
        emit Approval(ownerr, spender, amount);
    }
    
    function _spendAllowance(address owner1, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner1, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) revert InsufficientBalance();
            _approve(owner1, spender, currentAllowance - amount);
        }
    }
}