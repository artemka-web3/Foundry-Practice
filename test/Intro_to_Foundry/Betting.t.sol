// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/Intro_to_Foundry/Betting.sol";

contract BettingTest is Test {
    Betting public bettingContract;
    uint bettingDeadline;


    function setUp() public {
        vm.prank(address(0));
        bettingContract = new Betting();
    }
    receive() external payable {}

    
    function testPlaceBet() public {
        uint256 bettingContractBalance = address(bettingContract).balance;

        hoax(address(0), 100); // set up address with 100 ether
        bettingContract.placeBet{value: 1}();
        bettingContractBalance = address(bettingContract).balance;

        assertEq(bettingContractBalance, 1);
    }
    function testFailPlaceBet() public {
        uint256 bettingContractBalance = address(bettingContract).balance;

        hoax(address(0), 100); // set up address with 100 ether
        bettingContract.placeBet{value: 0}();
        bettingContractBalance = address(bettingContract).balance;

        assertEq(bettingContractBalance, 1);
    }


    function testClaimWinnings() public {
        startHoax(address(0), 100); // set up address with 100 ether
        bettingContract.placeBet{value: 1}();

        
        bettingContract.determineOutcome();

        bettingContract.claimWinnings();

        console.log("Winner balance: ", address(0).balance);
        assertEq(bettingContract.outcomeDetermined(), false);   
    }

    function testFailDetermineOutcome() public {
        vm.prank(address(1));
        bettingContract.determineOutcome();
    }
    function testDetermineOutcome() public {
        vm.prank(address(0));
        bettingContract.determineOutcome();
        assertEq(bettingContract.outcomeDetermined(), true);
    }

}