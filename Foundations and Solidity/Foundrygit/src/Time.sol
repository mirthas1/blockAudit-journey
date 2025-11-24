// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

contract Auction {
    uint256 public startAt = block.timestamp + 1 days;
    uint256 public endAt = block.timestamp + 2 days;


    function bid() external {
        require(block.timestamp >= startAt && block.timestamp < endAt,"can not bid");
    }

    function end() external {
        require(block.timestamp >= endAt, "cannot end");
    }
}