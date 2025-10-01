// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    mapping(address => uint256) public balances;
    constructor() {
        balances[msg.sender] = 1000; // Mint 1000 tokens to the deployer
    }
    function transfer(address to, uint256 amount) public { // Missing space between uint256 and amount)
          require(balances[msg.sender] >= amount, "Not Enougth Tokens");
           // Missing space between require and ()
           balances[msg.sender] -= amount;
            balances[to] += amount;
}}