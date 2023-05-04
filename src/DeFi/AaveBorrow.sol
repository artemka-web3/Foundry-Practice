// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "protocol-v2/contracts/interfaces/ILendingPool.sol";

contract AaveBorrow {
    address private constant AAVE_LENDING_POOL_ADDRESS = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address private constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    ILendingPool private lendingPool;

    constructor() {
        lendingPool = ILendingPool(AAVE_LENDING_POOL_ADDRESS);
    }

    function borrow(uint256 amount) external {
        // Approve AAVE lending pool to spend DAI on behalf of the borrower
        IERC20(DAI_ADDRESS).approve(AAVE_LENDING_POOL_ADDRESS, amount);

        // Borrow DAI from AAVE lending pool
        lendingPool.borrow(DAI_ADDRESS, amount, 2, 0, address(this));
    }
}
