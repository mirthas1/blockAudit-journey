// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

import "../src/IERC20Permit.sol";

contract GaslessTokenTransfer {
    function send(address token,
                  address sender,
                  address receiver,
                  uint256 amount,
                  uint256 fee,
                  uint256 deadline,
                  
                  uint8 v,
                  bytes32 r,
                  bytes32 s)

                  external {
        IERC20Permit(token).permit(
            sender, address(this),amount + fee, deadline,v,r,s
        );

        IERC20Permit(token).transferFrom(sender,receiver,amount);

        IERC20Permit(token).transferFrom(sender,msg.sender,fee);
                  }
}