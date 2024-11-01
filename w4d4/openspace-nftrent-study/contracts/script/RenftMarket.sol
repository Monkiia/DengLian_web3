// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/RenftMarket.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        // 部署合约实例
        RenftMarket nftMarket = new RenftMarket();

        // 打印合约地址
        console.log("Deployed contract at:", address(nftMarket));

        vm.stopBroadcast();
    }
}
