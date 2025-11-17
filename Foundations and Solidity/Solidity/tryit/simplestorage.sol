// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SimpleStorge {
    uint public number;
    function store(uint _num) public  {
        number = _num;
    }
    
    function retrive() public view returns (uint) {
        return number;
    }
}