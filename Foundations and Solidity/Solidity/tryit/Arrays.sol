// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
contract Array {
    string[] public names;

    function addname(string memory _name) public  {
        names.push(_name);
    }

    function getnemae(uint index) public view returns (string memory) {
        return names[index];
    }
}

