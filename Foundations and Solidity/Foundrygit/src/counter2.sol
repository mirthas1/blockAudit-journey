// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import "forge-std/console.sol";

contract counter2 {
    uint256 public count;
    int z = -12;

    function get() public view returns (uint256) {
        return count;
       
    }

    function inc() public {
        console.log("Here", count);
         console.log("hetere", z);
        count += 1;
    }

    function dec() public {
        console.log("here", count);
        count -= 1;
    }
}
