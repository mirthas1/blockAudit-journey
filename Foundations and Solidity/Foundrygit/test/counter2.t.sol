// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/counter2.sol";

contract counter2Test is Test {
    counter2 public counter;

    function setUp() public {
        counter = new counter2();
    }

    function testinc() public {
        counter.inc();
        assertEq(counter.count(), 1);
    }

    function testDecUnderflow() public {
        vm.expectRevert(stdError.arithmeticError);
        counter.dec();
    }

    function testdec() public {
        counter.inc();
        counter.inc();
        counter.inc();
        counter.dec();
        assertEq(counter.count(), 2);
    }
}
