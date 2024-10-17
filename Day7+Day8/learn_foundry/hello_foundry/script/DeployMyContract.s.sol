// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/MyContract.sol";

contract DeployMyContract is Script {
    function run() external {
        vm.startBroadcast();  // 开始发送交易
        
        // 部署合约
        MyContract myContract = new MyContract("Hello, Foundry!");

        vm.stopBroadcast();  // 停止发送交易
    }
}
