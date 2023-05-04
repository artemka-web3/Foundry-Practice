// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Betting {
    struct Bet {
        uint256 amount;
        address payable bettor;
    }
    
    Bet[] public bets;
    uint256 public outcome;
    bool public outcomeDetermined;

    address payable public owner;
    
    constructor() {
        owner = payable(msg.sender);
    }
    
    function placeBet() public payable {
        require(msg.value > 0, "Betting amount must be greater than zero");
        bets.push(Bet({
            amount: msg.value,
            bettor: payable(msg.sender)
        }));
    }
    
    function determineOutcome() public {
        require(msg.sender == owner, "Only owner can determine the outcome");
        outcome = block.number % 2; // Simple example, the outcome is either 0 or 1
        outcomeDetermined = true;
    }
    
    function claimWinnings() public {
        require(outcomeDetermined, "Outcome has not been determined yet");
        for (uint256 i = 0; i < bets.length;) {
            if ((outcome == 1 && i % 2 == 0) || (outcome == 0 && i % 2 != 0)) {
                bets[i].bettor.transfer(bets[i].amount);
            }
            unchecked{
                ++i;
            }
        }
        outcome = 0;
        outcomeDetermined = false;
        delete bets;
    }
    
    function refundBets() public {
        require(msg.sender == owner, "Only owner can refund bets");
        for (uint256 i = 0; i < bets.length;) {
            bets[i].bettor.transfer(bets[i].amount);
            unchecked{
                ++i;
            }
        }
        delete bets;
    }
}
