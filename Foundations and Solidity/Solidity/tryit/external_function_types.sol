// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

contract oracle{
    struct Request {
        bytes data;
        function(uint) external callback;
    }

    Request[] private requestes;
    event NewRequest(uint);

    function query(bytes memory data, function(uint) external callback) public {
        requestes.push(Request(data, callback));
        emit NewRequest(requestes.length -1);

    }

    function reply(uint requestID, uint response) public {
        requestes[requestID].callback(response);
    }


}

contract OracleUser{
    oracle constant private ORACLE_CONST = oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa));
    uint private exchangeRate;

    function buySomething() public {
        ORACLE_CONST.query("YEN", this.oracleResponse);
    }

    function oracleResponse(uint response) public {
        require(msg.sender == address(ORACLE_CONST),"only oracle can call this");
        exchangeRate = response;
    }
}