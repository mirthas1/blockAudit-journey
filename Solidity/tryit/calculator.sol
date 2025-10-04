// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 < 0.9.0;

contract calculator {
    //Add two numbers
    function Add(int a, int b) public pure returns (int) {
        return a + b;
    }
    
    //Subtract two numbers
    function Subtract(int a, int b) public pure returns (int) {
        return a-b;
    }
    //Multiply two numbers
    function Multiply(int a, int b) public pure returns (int) {
        return a*b;
    }
    //Divide two numbers
    function Divide(int a ,int b) public pure returns (int) {
        return a/b;
    }
}
