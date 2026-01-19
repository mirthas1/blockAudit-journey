// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {Auction} from "../src/Time.sol";

contract TimeTest is Test {
   Auction public auction;
   uint256 private startAt; 
    
    function setUp() public {
        auction = new Auction();
        startAt = block.timestamp;
    }


     function test_BidBeforeAuctionStartTime_ShouldRevert() public {
        vm.expectRevert("can not bid");
        auction.bid();
    }

    function testBid() public {
        vm.warp(auction.startAt());
        auction.bid();
    }

    function testbidFailAfterEndTime() public {
        vm.expectRevert();
        vm.warp(startAt + 2 days);
        auction.bid();
    }


    function testTimestamp() public {
        uint t = block.timestamp;

        skip(100);
        assertEq(block.timestamp, t+100);

        rewind(10);
        assertEq(block.timestamp,t+100-10);
    }


    function testBlockNumber()  public {
        vm.roll(999);
        assertEq(block.number, 999);
    }
}