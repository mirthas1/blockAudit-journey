// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

contract reen {
    mapping(address user => uint256 amounts) balances; 
    function with(uint amount) external {
        require(amount > 0, "Insufficiant balace");
        balances[msg.sender] -= amount;
        require(balances[msg.sender] > amount,"Insufficiant balace");

    }
}