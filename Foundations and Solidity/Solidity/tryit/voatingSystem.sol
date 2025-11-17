// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


contract SimpleVoting {
    mapping(address => bool ) public hasvoted;
    mapping(string => uint256) public voteCount;
    string[] public candidates;

    function addcandidate(string memory candidatename) public {
        candidates.push(candidatename);

    }

    function vote(string calldata candidatename) public {
        require(!hasvoted[msg.sender], "Already voted");
        require(isValidCandidate(candidatename), "Invalid Candidate");

        hasvoted[msg.sender] = true;
        voteCount[candidatename] += 1;

    }

    function isValidCandidate(string memory candidate) public view returns (bool) {
        for(uint i =0; i < candidates.length; i++){ 
            if(keccak256(abi.encodePacked(candidates[i])) == keccak256(abi.encodePacked(candidate))){
                return true;
            }
    }
    return false;
    }
    function getVoteCount(string memory candidate) public view returns (uint256) {
        return voteCount[candidate];
    }
   
function getAllCandidates() public view returns (string[] memory) {
    return candidates;
}
}