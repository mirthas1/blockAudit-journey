// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Mapping {
    mapping(address => uint) public balances;

    function deposit(uint _amount) public  {
        balances[msg.sender] = _amount;
    }
    
}

