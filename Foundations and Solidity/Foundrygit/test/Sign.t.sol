// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

import "forge-std/Test.sol";

contract SignTest is Test {


    function testSignsture() public {
        uint256 privateKey = 123;
        address pubkey = vm.addr(privateKey);

        bytes32 messageHash = keccak256("Secret message");

       (uint8 v, bytes32 r, bytes32 s)= vm.sign(privateKey, messageHash);

       address signer = ecrecover(messageHash, v, r, s);

       assertEq(signer, pubkey);

       bytes32 invalidMessageHash = keccak256("Invalid message");
       signer = ecrecover(invalidMessageHash, v, r, s);

       assertTrue(signer != pubkey);
    }
}