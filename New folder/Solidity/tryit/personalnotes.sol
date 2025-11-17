// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract PersonalNotes {
    string[] public notes;

    function addNote(string memory newNote) public  {
        notes.push(newNote);
    }

    function getNote(uint index) public view returns (string memory) {
        return notes[index];
    }
    function getcount() public view returns (uint) {
        return notes.length;
    }
}