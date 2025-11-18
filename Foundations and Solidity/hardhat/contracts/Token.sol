// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;
contract Tolen {
    string public name="MyToken";
    string public symbol="MT";
    uint256 public totalSupply=100000;
    address public owner;

    mapping(address => uint256) public balances;
    event Transfer(address indexed from,address indexed to, uint256 amount);

    constructor() {
    balances[msg.sender] = totalSupply;
    owner=msg.sender;    
    }

    function Tranferof(address to, uint256 value) external returns (bool) {
        require(balances[msg.sender] > value,"Insufficiant Tokens");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender,to,value);
        return true;
    }

    function balancessee(address account) public view  returns (uint256) {
        return balances[account];
    }
}