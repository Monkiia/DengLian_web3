// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/esRNT.sol";

contract DeployScript is Script {
    function run() external {
        // 使用指定的账户和 Anvil 上的资金部署合约
        vm.startBroadcast();
        esRNT esRntContract = new esRNT();
        vm.stopBroadcast();

        // 输出合约地址，便于测试
        console.log("esRNT deployed at:", address(esRntContract));
    }
}
