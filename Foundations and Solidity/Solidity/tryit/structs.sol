// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
contract structs {
    
    struct students {
        string name;
        uint age;
        bool passed;
    }

    students public mystudent;
    function setstudents(string memory _name, uint _age, bool _passed) public  {
        mystudent = students(_name, _age, _passed);
    }
}
