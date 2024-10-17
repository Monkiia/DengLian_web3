// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/mytoken.sol";

contract Deploymytoken is Script {
    function run() external {
        vm.startBroadcast();  // 开始发送交易
        
        // 部署合约
        MyToken myToken = new MyToken("EDC","EDC");

        vm.stopBroadcast();  // 停止发送交易
    }
}
