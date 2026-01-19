// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title HolidayVilla — Basic booking
/// @notice Minimal fixed version: pay exactly minPrice (or more) to book if available
contract HolidayVillaBasic {
    address payable public immutable owner;
    enum VillaStatus { Available, Booked }
    VillaStatus public currentVillaStatus;
    uint256 public constant MIN_PRICE = 1 ether;

    event VillaBooked(address indexed renter, uint256 value);

    error VillaAlreadyBooked();
    error InsufficientPayment(uint256 sent, uint256 required);

    constructor() {
        owner = payable(msg.sender);
        currentVillaStatus = VillaStatus.Available;
    }

    modifier whenAvailable() {
        if (currentVillaStatus != VillaStatus.Available) revert VillaAlreadyBooked();
        _;
    }

    function bookVilla() external payable whenAvailable {
        if (msg.value < MIN_PRICE) revert InsufficientPayment(msg.value, MIN_PRICE);

        // Effect
        currentVillaStatus = VillaStatus.Booked;

        // Interaction
        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Transfer to owner failed");

        emit VillaBooked(msg.sender, msg.value);
    }

    /// @notice Read-only helper that returns true if booked
    function isBooked() external view returns (bool) {
        return currentVillaStatus == VillaStatus.Booked;
    }
}
