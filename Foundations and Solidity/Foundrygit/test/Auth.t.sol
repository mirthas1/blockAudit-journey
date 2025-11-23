// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";

contract AuthTest is Test {
    Wallet public wallet;
    address owner = address(this); // Test contract is initial owner
    address user1 = address(1);

    function setUp() public {
        wallet = new Wallet();
    }

    function testSetOwner_Success() public {
        // Test contract should be able to set new owner initially
        wallet.setowner(user1);
        assertEq(wallet.owner(), user1);
    }

    function testSetOwner_RevertWhenNotOwner() public {
        // Non-owner should not be able to set owner
        vm.prank(user1);
        vm.expectRevert(); // Expect some revert (Unauthorized, Ownable, etc.)
        wallet.setowner(user1);
    }

    function testSetOwner_OnlyNewOwnerCanSetAfterTransfer() public {
        // Transfer ownership
        wallet.setowner(user1);
        
        // New owner should be able to set subsequent owners
        vm.startPrank(user1);
        wallet.setowner(address(2));
        assertEq(wallet.owner(), address(2));
        vm.stopPrank();
        
        // Old owner should no longer have permission
        vm.expectRevert();
        wallet.setowner(address(3));
    }
}