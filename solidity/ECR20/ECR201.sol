// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    /*contract → like a class in other languages.

MiniToken → the name of your contract.

Everything inside { ... } is part of this contract */

    mapping(address => uint256) public balances;
/*mapping → a dictionary: stores key → value pairs.

address → the key type (like a wallet).

uint256 → the value type (big number, e.g., token amount).

public → allows anyone to read balances from outside the contract.*/



    constructor() {
        balances[msg.sender] = 1000; // Mint 1000 tokens to the deployer
    }
/*constructor → a function that runs once when the contract is deployed.

msg.sender → the address that is deploying the contract.

balances[msg.sender] = 1000 → gives the deployer 1000 tokens initially.*/


    function transfer(address to, uint256 amount) public { // Missing space between uint256 and amount)
          require(balances[msg.sender] >= amount, "Not Enougth Tokens");
           // Missing space between require and ()
           balances[msg.sender] -= amount;
            balances[to] += amount;
            /*function → defines a callable operation inside the contract.

transfer → name of the function.

address to, uint256 amount → parameters passed when calling.

public → anyone can call this function.

require(condition, "error") → check that a condition is true, otherwise stop.

balances[msg.sender] -= amount → subtract from sender.

balances[to] += amount → add to recipient.*/
}}