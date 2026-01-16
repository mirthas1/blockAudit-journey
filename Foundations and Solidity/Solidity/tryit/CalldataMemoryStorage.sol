// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract DataLocations {
    struct MyStruct {
        uint256 value;
        string name;
    }
    
    MyStruct[] public structArray; // Storage array
    
    function demonstrateLocations() external {
        // _inputStruct is in CALLDATA - read-only, cheapest
        
        // Local variables - use MEMORY for complex types
        MyStruct memory localStruct = MyStruct(123, "memory example");
        
        // Working with storage - EXPENSIVE
        structArray.push(localStruct); // Writing to storage - high gas cost
        
        // Common MISTAKE - incorrect data location
        MyStruct storage storedItem = structArray[0]; // Reference to storage
        storedItem.value = 456; // This MODIFIES the actual storage!
        
        // Correct way if you want a temporary copy:
        MyStruct memory tempCopy = structArray[0]; // Copy to memory
        tempCopy.value = 789; // This does NOT affect storage
    }
}