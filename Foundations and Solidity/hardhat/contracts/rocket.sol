// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract rocket {
    string public name;
    string public status;

    function setname (string memory _name) public  {
           name = _name;
           status = "ignition";
    }

    function launch() public  {
        status = "lift-coff";
    } 
}