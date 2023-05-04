// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract TimeLockedSavings is Ownable {
    IERC20 public token;
    address public beneficiary;
    uint256 public releaseTime;
    uint256 public amount;

    event FundsLocked(address indexed beneficiary, uint256 amount, uint256 releaseTime);
    event FundsReleased(address indexed beneficiary, uint256 amount);

    constructor(IERC20 _token, address _beneficiary, uint256 _releaseTime, uint256 _amount) {
        require(_releaseTime > block.timestamp, "Release time must be in the future");
        require(_amount > 0, "Amount must be greater than 0");
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
        amount = _amount;
    }

    function lockFunds() public {
        require(token.allowance(msg.sender, address(this)) >= amount, "Token allowance not set");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        emit FundsLocked(beneficiary, amount, releaseTime);
    }

    function releaseFunds() public onlyOwner {
        require(block.timestamp >= releaseTime, "Release time has not been reached");
        require(token.transfer(beneficiary, amount), "Token transfer failed");
        emit FundsReleased(beneficiary, amount);
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function setReleaseTime(uint256 _releaseTime) public onlyOwner {
        require(_releaseTime > block.timestamp, "Release time must be in the future");
        releaseTime = _releaseTime;
    }

    function setAmount(uint256 _amount) public onlyOwner {
        amount = _amount;
    }
}
