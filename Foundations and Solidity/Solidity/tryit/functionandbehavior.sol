// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VisibilityDemo {
    string private secretword = "Hidden";
    string public PublicWord = "Visible";

    function showsecret() private view returns (string memory) {
        return secretword;
    }
    function showpublic() public view returns (string memory) {
        return  PublicWord;
    }
}
contract Behaviordemo {
    int public number = 10;
    function getnumber() public view returns (int) {
        return number;
    }
    function add(int a, int b) public pure returns (int) {
        return a + b ;
    }
    function setnumber(int _num) public  {
        number = _num;
    }
    
}