// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 < 0.9.0;

contract calculator {
    //Add two numbers
    function Add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }
    
    //Subtract two numbers
    function Subtract(uint a, uint b) public pure returns (uint) {
        return a-b;
    }
    //Multiply two numbers
    function Multiply(uint a, uint b) public pure returns (uint) {
        return a*b;
    }
    //Divide two numbers
    function Divide(uint a ,uint b) public pure returns (uint) {
        return a/b;
    }
}
