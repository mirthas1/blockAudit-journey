// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Securenotes {
    address public owner;
    string[] private notes;
    mapping(address => uint) public deposits;

    event NoteAdded(address indexed by, uint indexed index);
    event NoteDeleted(address indexed by, uint indexed index);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner); // Fixed

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function addnote(string calldata text) external {
        notes.push(text);
        uint idx = notes.length - 1;
        emit NoteAdded(msg.sender, idx);
    }

    function getnote(uint idx) external view returns (string memory) {
        require(idx < notes.length, "Index OOB");
        return notes[idx]; // Added return statement
    }

    function getcount() external view returns (uint) {
        return notes.length;
    }

    function deletenote(uint idx) external onlyOwner {
        require(idx < notes.length, "Index OOB"); // Fixed typo
        delete notes[idx];
        emit NoteDeleted(msg.sender, idx);
    }

    function deposit() external payable {
        require(msg.value > 0, "Zero");
        deposits[msg.sender] += msg.value;
    }

    function ownerWithdraw(address payable to) external onlyOwner {
        uint bal = address(this).balance;
        require(bal > 0, "Zero Balance");
        (bool ok, ) = to.call{value: bal}("");
        require(ok, "Transfer Failed");
    }

    function changeowner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero Address"); // Fixed typo
        require(newOwner != owner, "Same owner");
        emit OwnerChanged(owner, newOwner); // Fixed event parameters
        owner = newOwner;
    }
}