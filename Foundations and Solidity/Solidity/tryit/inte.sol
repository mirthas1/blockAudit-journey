// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract pus {
    

    function get(uint num, uint kum) public pure returns(uint) {
        uint256 sum;
       sum = num / kum ;
        return sum;
    }

}