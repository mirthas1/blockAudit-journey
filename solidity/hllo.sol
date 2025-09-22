// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private storedNumber;
    
    // Event to log number changes
    event NumberChanged(uint256 newNumber);
    
    // Store a number
    function storeNumber(uint256 _number) public {
        storedNumber = _number;
        emit NumberChanged(_number);
    }
    
    // Retrieve the stored number
    function getNumber() public view returns (uint256) {
        return storedNumber;
    }
    
    // Function to add to the stored number
    function addToNumber(uint256 _value) public {
        storedNumber += _value;
        emit NumberChanged(storedNumber);
    }
}