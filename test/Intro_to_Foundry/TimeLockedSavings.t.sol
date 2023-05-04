// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/Intro_to_Foundry/TimeLockedSavings.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract TimeLockedSavingsTest is Test {
    TimeLockedSavings public testContract;
    IERC20 public constant DAI = IERC20(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
    // address(0x40A3Bb5933DFfF4b1978b0e6e1f582a292E55585) - contract deployer
    // address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e) benficiary - human who locked tokens
    uint256 public amount = 100;
    uint256 public releaseTime;

    // events
    event FundsLocked(address indexed beneficiary, uint256 amount, uint256 releaseTime);
    event FundsReleased(address indexed beneficiary, uint256 amount);

    // important data
    uint256 mainnetFork;
    string public MUMBAI_URL_TIMELOCKEDSAVINGS = vm.envString("MUMBAI_URL_TIMELOCKEDSAVINGS");


    function setUp() public {
        mainnetFork = vm.createFork(MUMBAI_URL_TIMELOCKEDSAVINGS);
        vm.selectFork(mainnetFork);
        releaseTime = block.timestamp + 1 days;
        vm.prank(address(0x40A3Bb5933DFfF4b1978b0e6e1f582a292E55585));
        testContract = new TimeLockedSavings(DAI, address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e), releaseTime, amount);
    }
    function testLockFunds() public {
        vm.selectFork(mainnetFork);
        console.log("Time Locked Savings: ", DAI.balanceOf(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e)));
        console.log("Time Locked Savings: ", DAI.balanceOf(address(testContract)));

        vm.startPrank(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e));
        DAI.approve(address(testContract), amount);

        vm.expectEmit(true, false, false, true);
        emit FundsLocked(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e), amount, releaseTime);

        testContract.lockFunds();
        vm.stopPrank();

        console.log("Time Locked Savings: ", DAI.balanceOf(address(testContract)));
        console.log("Time Locked Savings: ", DAI.balanceOf(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e)));



    }
    function testFailLockFunds() public {
        vm.selectFork(mainnetFork);
        vm.startPrank(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e));
        DAI.approve(address(testContract), amount - 50);
        testContract.lockFunds();
        vm.stopPrank();
    }

    function testReleaseFunds() public {
        // lockFunds
        vm.selectFork(mainnetFork);
        vm.startPrank(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e));
        DAI.approve(address(testContract), amount);
        testContract.lockFunds();
        vm.stopPrank();

        vm.startPrank(0x40A3Bb5933DFfF4b1978b0e6e1f582a292E55585);
        vm.warp(releaseTime + 2 days);
        vm.expectEmit(true, false, false, true);
        emit FundsReleased(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e), amount);
        testContract.releaseFunds();
        assertEq(DAI.balanceOf(address(testContract)), 0);
        vm.stopPrank();
    }

    function testFailReleaseFundsBeforeDeadline() public {
        vm.selectFork(mainnetFork);
        vm.startPrank(address(0xCE6Add54ad6715c73e6fbA41C225b9648F0a054e));
        DAI.approve(address(testContract), amount);
        testContract.lockFunds();
        vm.stopPrank();

        vm.startPrank(0x40A3Bb5933DFfF4b1978b0e6e1f582a292E55585);
        vm.warp(releaseTime - 2 days);
        testContract.releaseFunds();
        
    } 
}