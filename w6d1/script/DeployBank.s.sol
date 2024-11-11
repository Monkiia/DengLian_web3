// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Bank.sol";

contract DeployBank is Script {
    function run() external {
        // 设定存款阈值，例如 0.1 ether
        uint256 threshold = 0.1 ether;

        // 开始广播交易
        vm.startBroadcast();

        // 部署 Bank 合约，并传入阈值
        Bank bank = new Bank(threshold);

        // 停止广播
        vm.stopBroadcast();

        // 输出 Bank 合约地址
        console.log("Bank contract deployed at:", address(bank));
    }
}
