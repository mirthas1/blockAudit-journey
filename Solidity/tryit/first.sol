// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
contract HelloSolidity {
    string public message = "Hello, Blockchain";
    function SayMessage() public view returns (string memory) {
        return message;
    }
}