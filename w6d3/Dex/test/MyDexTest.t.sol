// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/MyDex.sol";
import "../src/RNT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyDexTest is Test {
    MyDex public dex;
    RNT public rnt;
    IUniswapV2Router02 public router;
    address public constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public user;

    function setUp() public {
        // 部署 RNT 代币并设置初始供应量
        rnt = new RNT(1000000 ether);

        // 部署 MyDex 合约
        dex = new MyDex(UNISWAP_V2_ROUTER);

        // 初始化用户地址
        user = address(this);

        // 将初始 RNT 代币分配给用户
        rnt.transfer(user, 1000 ether);

        // 添加 RNT 和 ETH 的初始流动性
        vm.prank(user);
        rnt.approve(UNISWAP_V2_ROUTER, 500 ether);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidityETH{value: 5 ether}(
            address(rnt),
            500 ether,
            0,
            0,
            user,
            block.timestamp
        );
    }


    function testSellETHForRNT() public {
        uint256 initialRntBalance = rnt.balanceOf(user);
        
        // 用户卖出 1 ETH 兑换成 RNT
        uint256 amountInETH = 1 ether;
        uint256 minRntOut = 1; // 最小的 RNT 数量，用于确保交易成功

        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = address(rnt);

        vm.deal(user, amountInETH); // 给用户账户预置 ETH

        // 执行 sellETH 操作
        vm.prank(user);
        dex.sellETH{value: amountInETH}(address(rnt), minRntOut);

        // 获取卖出 ETH 后的 RNT 余额
        uint256 finalRntBalance = rnt.balanceOf(user);
        assert(finalRntBalance > initialRntBalance);
        emit log_named_uint("RNT Received:", finalRntBalance - initialRntBalance);
    }

    function testBuyETHWithRNT() public {
        uint256 initialEthBalance = address(user).balance;
        
        // 用户买入 0.5 ETH，出售 RNT
        uint256 amountInRNT = 10 ether;
        uint256 minEthOut = 0.001 ether; // 最小的 ETH 数量，用于确保交易成功

        // 用户授权 RNT 代币给 MyDex
        vm.prank(user);
        rnt.approve(address(dex), amountInRNT);

        // 执行 buyETH 操作
        vm.prank(user);
        dex.buyETH(address(rnt), amountInRNT, minEthOut);

        // 获取买入 ETH 后的余额变化
        uint256 finalEthBalance = address(user).balance;
        assert(finalEthBalance > initialEthBalance);
        emit log_named_uint("ETH Received:", finalEthBalance - initialEthBalance);
    }

    // 回退函数，用于接收 ETH
    receive() external payable {}
}
