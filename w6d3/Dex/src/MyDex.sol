// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "v2-periphery/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyDex {
    IUniswapV2Router02 public immutable router;

    constructor(address _router) {
        router = IUniswapV2Router02(_router);
    }

    /**
     * @dev 卖出ETH，兑换成任意ERC20代币
     * @param buyToken 兑换的目标代币地址
     * @param minBuyAmount 要求最低兑换到的目标代币数量
     */
    function sellETH(address buyToken, uint256 minBuyAmount) external payable {
        require(buyToken != address(0), "Invalid token address");

        address[] memory path = new address[](2);
        path[0] = router.WETH(); // 从ETH开始
        path[1] = buyToken; // 目标代币

        router.swapExactETHForTokens{value: msg.value}(
            minBuyAmount,
            path,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev 买入ETH，用任意ERC20代币兑换
     * @param sellToken 出售的代币地址
     * @param sellAmount 出售的代币数量
     * @param minBuyAmount 要求最低兑换到的ETH数量
     */
    function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external {
        require(sellToken != address(0), "Invalid token address");

        // 获取sellToken合约实例
        IERC20 token = IERC20(sellToken);

        // 将sellToken转入合约并授权给Router
        token.transferFrom(msg.sender, address(this), sellAmount);
        token.approve(address(router), sellAmount);

        address[] memory path = new address[](2);
        path[0] = sellToken; // 出售的代币
        path[1] = router.WETH(); // 兑换到ETH

        router.swapExactTokensForETH(
            sellAmount,
            minBuyAmount,
            path,
            msg.sender,
            block.timestamp
        );
    }
}
