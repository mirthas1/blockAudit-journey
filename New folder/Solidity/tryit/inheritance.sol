// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// BASE CONTRACT
contract Ownable {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

// INTERFACE - Fixed: added transferFrom
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool); // ADDED THIS
    function balanceOf(address account) external view returns (uint256);
}

// MAIN CONTRACT - Fixed
contract TokenVault is Ownable {
    mapping(address => uint256) public deposits;
    IERC20 public token;
    
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }
    
    function deposit(uint256 amount) public {
        // FIXED: Now using transferFrom which requires approval first
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        deposits[msg.sender] += amount;
    }
    
    function withdraw(uint256 amount) public {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }
}