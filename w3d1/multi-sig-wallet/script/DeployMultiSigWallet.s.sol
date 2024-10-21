// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/MultiSigWallet.sol";

contract DeployMultiSigWallet is Script {
    function run() external {
        // Declare and initialize test addresses
        address owner1 = vm.addr(1);
        address owner2 = vm.addr(2);
        address owner3 = vm.addr(3);

        // Define owner addresses array
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the MultiSigWallet contract
        MultiSigWallet wallet = new MultiSigWallet(owners);

        // Log the contract address
        console.log("MultiSigWallet deployed at:", address(wallet));

        // Optionally, perform some contract interactions
        wallet.propose(address(0xABC), 100);
        console.log("Proposal made by owner1");

        vm.stopBroadcast();
    }
}
