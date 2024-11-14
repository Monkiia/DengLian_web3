// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "v2-periphery/interfaces/IERC20.sol";
import {console} from "forge-std/console.sol";

contract Interact is Script {
    function run() external {
        // 使用 fork 网络上的 Uniswap V2 Router 地址
        IUniswapV2Router02 router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        // 示例：调用交换函数
        address tokenIn = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH地址
        address tokenOut = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC地址
        uint amountIn = 1 ether;
        uint amountOutMin = 1;

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // 记录交换前的 USDC 余额
        IERC20 usdc = IERC20(tokenOut);
        uint256 balanceBefore = usdc.balanceOf(msg.sender);
        console.log("USDC Balance Before Swap:", balanceBefore);

        // 执行交换操作
        router.swapExactETHForTokens{value: amountIn}(amountOutMin, path, msg.sender, block.timestamp);
        console.log("Success swapExactETHForTokens");

        // 获取交换后的 USDC 余额
        uint256 balanceAfter = usdc.balanceOf(msg.sender);
        console.log("USDC Balance After Swap:", balanceAfter);

        // 计算并输出收到的 USDC 数量
        uint256 receivedAmount = balanceAfter - balanceBefore;
        console.log("USDC Received:", receivedAmount);
    }
}
