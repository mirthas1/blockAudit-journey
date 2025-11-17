// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30 < 0.9.0;

contract myfirstToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalsupply;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    event Transfer(address indexed to, address indexed fron, uint256 value);
    event Approve(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialsupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalsupply = _initialsupply * 10 ** _decimals;
        _balances[msg.sender] = totalsupply;

        emit Transfer(address(0), msg.sender, totalsupply);
    }

    function Balanceof(address account) public view returns(uint256 balance) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender,to,amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256 remaining) {
        return _allowances[owner][spender];
    }
     function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender,spender,amount);
        return true;
    }

    function transferfrom(address from,address to,uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to , amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address (0), "transfer from the zero address");
        require (from != address(0),"transfer to the zero account");

        uint256 fromBalance = _balances[from];
        require (fromBalance >= amount, "transfer amount exceeds the balance");

        _balances[from]= fromBalance - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

     function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approve(owner, spender, amount);
     }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
     uint256 currentAllowance =allowance(owner, spender);
     if (currentAllowance != type(uint256).max) {
        require(currentAllowance >=amount, "ECR20: insufficiant allowance");
        _approve(owner, spender, currentAllowance - amount);
     }
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns(bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+addedValue);
        return true;
    }

    function decreaseAllowannce(address spender, uint256 subtractedValue) public returns(bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue,"ECR20: decreased Allowance below zero");
        _approve(msg.sender, spender, currentAllowance-subtractedValue);
        return true;
    }

    function burn(uint256 amount) public {
        require(_balances[msg.sender] >= amount, "ERC20: burn amount exceeds balance");
        _balances[msg.sender] -= amount;
        totalsupply -= amount;
        totalsupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

   
}