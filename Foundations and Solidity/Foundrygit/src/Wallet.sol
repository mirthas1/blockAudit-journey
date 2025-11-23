// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract Wallet {
    address payable public owner;

    constructor() payable {
        owner= payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner,"not owner");
        payable(msg.sender).transfer(_amount);
    }

    function setowner(address _newowner) external {
        require(msg.sender == owner, "not owner");
        owner= payable(_newowner);
    }

}