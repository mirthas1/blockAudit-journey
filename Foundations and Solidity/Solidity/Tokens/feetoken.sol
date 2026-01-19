// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract FeeToken {
    // Storage (we've covered this)
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // New: Fee mechanism (using known concepts)
    address public feeCollector;
    uint256 public transferFee; // 100 = 1%, 500 = 5%
    
    // Events (we know these)
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FeeCollected(address indexed from, uint256 feeAmount);
    
    // Errors (we know these)
    error InsufficientBalance();
    error ZeroAddress();
    error InvalidFee();
    
    // Modifiers (we know these)
    modifier onlyFeeCollector() {
        require(msg.sender == feeCollector, "Not fee collector");
        _;
    }
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        address _feeCollector,
        uint256 _transferFee
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**_decimals;
        feeCollector = _feeCollector;
        
        if (_transferFee > 1000) revert InvalidFee(); // Max 10% fee
        transferFee = _transferFee;
        
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        _transferWithFee(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transferWithFee(from, to, amount);
        return true;
    }
    
    // NEW: Internal function with fee logic
    function _transferWithFee(address from, address to, uint256 amount) internal {
        if (from == address(0)) revert ZeroAddress();
        if (to == address(0)) revert ZeroAddress();
        
        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) revert InsufficientBalance();
        
        // Calculate and collect fee
        uint256 feeAmount = (amount * transferFee) / 10000;
        uint256 netAmount = amount - feeAmount;
        
        // Update balances
        _balances[from] = fromBalance - amount;
        _balances[to] += netAmount;
        
        // Send fee to collector
        if (feeAmount > 0) {
            _balances[feeCollector] += feeAmount;
            emit FeeCollected(from, feeAmount);
        }
        
        emit Transfer(from, to, netAmount);
        if (feeAmount > 0) {
            emit Transfer(from, feeCollector, feeAmount);
        }
    }
    
    // Using known patterns for approval system
    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) revert ZeroAddress();
        if (spender == address(0)) revert ZeroAddress();
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) revert InsufficientBalance();
            _approve(owner, spender, currentAllowance - amount);
        }
    }
    
    // Admin functions using known concepts
    function updateFee(uint256 newFee) public onlyFeeCollector {
        if (newFee > 1000) revert InvalidFee();
        transferFee = newFee;
    }
    
    function updateFeeCollector(address newCollector) public onlyFeeCollector {
        if (newCollector == address(0)) revert ZeroAddress();
        feeCollector = newCollector;
    }
}