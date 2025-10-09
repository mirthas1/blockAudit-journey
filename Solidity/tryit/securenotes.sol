// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
contract SecureNotes {
    address public owner;
    string[] private notes;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner!");
    _;}

    function addnote(string memory newnote) public onlyOwner {
        notes.push(newnote);
    }

    function getnote(uint index) public view returns (string memory) {
        return notes[index];
    }

    function getcount() public view returns (uint) {
        return notes.length;
    }

    function deletenote(uint index) public onlyOwner {
        delete notes[index];
    }
}