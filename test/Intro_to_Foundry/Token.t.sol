// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Intro_to_Foundry/Token.sol";


contract TokenTest is Test {
    // contract variable
    MyToken public tokenContract;

    // address(1) owner of total supply
    // address(2) token receiver

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        // create Token contract with initial vals
        vm.prank(address(1));
        tokenContract = new MyToken("MyToken", "MTK", 18, 1_000_000);
    }

    function testTransfer() public {
        // testing function execution
        vm.startPrank(address(1));
        // testing event(indexed param, indexed param, indexed param, data)
        vm.expectEmit(true, true, false, true);
        // 2. Emit the expected event
        emit Transfer(address(1), address(2), 1_000);
        tokenContract.transfer(address(2), 1_000);
        assertEq(tokenContract.balanceOf(address(2)), 1_000);
        assertEq(tokenContract.balanceOf(address(1)), 999_000);
        vm.stopPrank();

        // // testing event(indexed param, indexed param, indexed param, data)
        // vm.expectEmit(true, true, false, true);
        // // 2. Emit the expected event
        // emit Transfer(address(1), address(2), 1_000);
        // // 3. Call the function that should emit the event
        // tokenContract.transfer(address(2), 500);


        console.log("balance of owner of total supply", tokenContract.balanceOf(address(1)));
        console.log("balance of receiver", tokenContract.balanceOf(address(2)));
    }

    function testFailTransfer() public {
        vm.startPrank(address(1));
        tokenContract.transfer(address(2), 1_000_001);
        assertEq(tokenContract.balanceOf(address(2)), 1_000);
        assertEq(tokenContract.balanceOf(address(1)), 999_000);
        vm.stopPrank();
        console.log("balance of owner of total supply", tokenContract.balanceOf(address(1)));
        console.log("balance of receiver", tokenContract.balanceOf(address(2)));
    }
    function testTransferFrom() public {
        vm.startPrank(address(1));
        tokenContract.approve(address(1), 1_000);
        tokenContract.transferFrom(address(1), address(2), 1_000);
        assertEq(tokenContract.allowance(address(1), address(2)), 0);
        assertEq(tokenContract.balanceOf(address(1)), 999_000);
        assertEq(tokenContract.balanceOf(address(2)), 1_000);
        vm.stopPrank();
    }
    function testFailTransferFrom() public {
        vm.startPrank(address(1));
        tokenContract.approve(address(1), 500);
        tokenContract.transferFrom(address(1), address(2), 1_000);
        assertEq(tokenContract.allowance(address(1), address(2)), 0);
        assertEq(tokenContract.balanceOf(address(1)), 999_000);
        assertEq(tokenContract.balanceOf(address(2)), 1_000);
        vm.stopPrank();
    }


    function testApprove() public {
        vm.startPrank(address(1));
        tokenContract.approve(address(2), 1_000);
        assertEq(tokenContract.allowance(address(1), address(2)), 1_000);
        vm.stopPrank();
    }
}