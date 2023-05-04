// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    Candidate[] public candidates;
    mapping(address => bool) public voters;
    uint256 public totalVotes;

    event Voted(address indexed voter, uint256 indexed candidateId);

    constructor(string[] memory _candidateNames) {
        for (uint256 i = 0; i < _candidateNames.length; i++) {
            candidates.push(Candidate({
                name: _candidateNames[i],
                voteCount: 0
            }));
        }
    }

    function vote(uint256 _candidateId) public {
        require(!voters[msg.sender], "Already voted");
        require(_candidateId < candidates.length, "Invalid candidate");
        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        totalVotes++;
        emit Voted(msg.sender, _candidateId);
    }

    function getWinner() public view returns (string memory winnerName) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerName = candidates[i].name;
            }
        }
    }
}