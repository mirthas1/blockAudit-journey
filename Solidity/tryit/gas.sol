//  SPDX-LICENCE-IDENTIFIER: MIT
pragma solidity ^0.8.30;

contract SlotAnalysis {
    uint256 public a;    // slot 0
    uint128 public b;    // slot 1
    uint128 public c;    // slot 1 (packed with b)
    uint256 public d;    // slot 2
    bool public e;       // slot 3
    address public f;    // slot 4
    uint64 public g;     // slot 5
    uint64 public h;     // slot 5 (packed with g)
    uint64 public i;     // slot 5 (packed)
}