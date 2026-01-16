// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract Event {
    event Transfer(address indexed from,address indexed to, uint256 amount);

    function transfer2(address from, address to ,uint256 value) public {
        emit Transfer(from,to,value);
    }

    function transfermany(address from, address[] calldata to, uint256[] calldata amounts) external {
        for (uint256 i=0; i < to.length; i++) {
            emit Transfer(from, to[i], amounts[i]);
        }
    }
}