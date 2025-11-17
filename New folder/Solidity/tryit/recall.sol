// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fundamentals {
    uint256 public number;
    address public owner;
    string public message;

    event NumberUpdated(uint256 oldnumber, uint256 newnumber);

    constructor() {
        owner = msg.sender;
        number = 100;
        message= "Hello again";
    }

    modifier onlyowner(){
        require(msg.sender == owner, "Not the Owner");
        _;
    }

    function updatenumber(uint256 _nwewnumber ) public onlyowner {
        uint256 oldnumber = number;
        number = _nwewnumber;
        emit NumberUpdated(oldnumber , _nwewnumber);
    }
}