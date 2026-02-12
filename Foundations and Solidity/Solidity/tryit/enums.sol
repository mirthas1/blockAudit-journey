// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract enum1 {

    enum ActionChoices {Goleft, GoRight, GoSraight, Sitstill}
    ActionChoices choices;
    ActionChoices constant defaultChoice = ActionChoices.GoSraight;

    function setgostraight() public {
        choices = ActionChoices.GoSraight;
    }

    /*since enum types are not part of the ABI, the signature of "getChoice"
    will automatically be changed to "getChoice() returns uint(8)"
    for all matters external to solidity
    */ 

   function getChoice() public view returns (ActionChoices) {
    return choices;
   }

   function getdefaultchoice() public pure returns (uint8) {
    return uint8(defaultChoice);
   }

   function getlargestvalue() public pure  returns (ActionChoices) {
    return type(ActionChoices).max;
   }

   function getlowestvalue() public pure returns(ActionChoices) {
    return type(ActionChoices).min;
   }

}