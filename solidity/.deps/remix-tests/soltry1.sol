// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract HelloWorld {
    string public message = "Hello, blockchain!"; 

    function sayMessage() public view returns (string memory) {
      return message;  
    }
        
    
}
/* 
pragma → like telling the computer which grammar rules to use.

contract → like a box that holds everything.

variable → a small container inside the box that holds data.

function → an action the box can do.
*/