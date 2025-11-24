// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/IERC20.sol";

contract ForkTest is Test {
   IERC20 public dai;

    function setUp() public {
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function testDeposit() public {
        address mona = address(369);

        uint256 balBefore = dai.balanceOf(mona);
        console.log("total supply before", balBefore);

        uint256 totalBefore = dai.totalSupply();
        console.log("total supply before", totalBefore/ 1e18);

        deal(address(dai), mona, 1e6*1e18, true);

        uint256 balAfter = dai.balanceOf(mona);
        console.log("balance after", balAfter / 1e18);

        uint256 totalAfter= dai.totalSupply();
        console.log("total supply after", totalAfter/1e18);

    }

}