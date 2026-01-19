// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MintableBurnableToken {
    // Storage (all concepts we know)
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public maxSupply;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Access control using known patterns
    address public owner;
    mapping(address => bool) public minters;
    mapping(address => bool) public burners;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event MinterUpdated(address indexed account, bool status);
    event BurnerUpdated(address indexed account, bool status);
    
    // Errors
    error InsufficientBalance();
    error ZeroAddress();
    error NotOwner();
    error NotMinter();
    error NotBurner();
    error ExceedsMaxSupply();
    
    // Modifiers (using known patterns)
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
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        uint256 _maxSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        maxSupply = _maxSupply * 10**_decimals;
        
        owner = msg.sender;
        minters[msg.sender] = true;
        burners[msg.sender] = true;
        
        // Mint initial supply
        _mint(msg.sender, _initialSupply * 10**_decimals);
    }
    
    // === STANDARD ERC20 FUNCTIONS ===
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner1, address spender) public view returns (uint256) {
        return _allowances[owner1][spender];
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    // === MINTING FUNCTIONALITY ===
    function mint(address to, uint256 amount) public onlyMinter {
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
    
    // === BURNING FUNCTIONALITY ===
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    function burnFrom(address from, uint256 amount) public onlyBurner {
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
    
    // === ACCESS CONTROL MANAGEMENT ===
    function addMinter(address account) public onlyOwner {
        minters[account] = true;
        emit MinterUpdated(account, true);
    }
    
    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
        emit MinterUpdated(account, false);
    }
    
    function addBurner(address account) public onlyOwner {
        burners[account] = true;
        emit BurnerUpdated(account, true);
    }
    
    function removeBurner(address account) public onlyOwner {
        burners[account] = false;
        emit BurnerUpdated(account, false);
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        owner = newOwner;
    }
    
    // === INTERNAL FUNCTIONS (Reusing known patterns) ===
    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0)) revert ZeroAddress();
        if (to == address(0)) revert ZeroAddress();
        
        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) revert InsufficientBalance();
        
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }
    
    function _approve(address owner2, address spender, uint256 amount) internal {
        if (owner2 == address(0)) revert ZeroAddress();
        if (spender == address(0)) revert ZeroAddress();
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner3, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner3, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) revert InsufficientBalance();
            _approve(owner3, spender, currentAllowance - amount);
        }
    }
}