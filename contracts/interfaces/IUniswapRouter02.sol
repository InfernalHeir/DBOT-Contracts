// SPDX-License-Identifier: MIT;
pragma solidity ^0.7.0;

interface IUniswapRouter02{
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
