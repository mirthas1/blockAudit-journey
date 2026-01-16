// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {Error} from "../src/Error.sol";

contract ErrorTeat is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }

    function testreverte() public  {
        vm.expectRevert();
        err.throwError();
    }
}