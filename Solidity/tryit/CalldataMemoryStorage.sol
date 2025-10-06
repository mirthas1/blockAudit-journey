// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract CMS {
    string public ToyInbox;

    function Calldta( string calldata newtoy ) public  {
        string memory temporarycopy = newtoy;
        temporarycopy = "I can change this!";
        ToyInbox = temporarycopy;
    }

    function cheapway(string calldata toyname) public pure returns (string memory) {
        
        return string(abi.encodePacked("I got: ", toyname));
    }
}