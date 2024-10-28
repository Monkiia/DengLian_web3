// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/InscriptionFactory.sol";

contract DeployInscriptionFactory is Script {
    function run() external {
        // Start broadcasting a transaction using the private key
        vm.startBroadcast();

        // Deploy the InscriptionFactory contract
        InscriptionFactory factory = new InscriptionFactory();

        // Log the deployed address for verification
        console.log("InscriptionFactory deployed to:", address(factory));

        // Deploy a new InscriptionToken using the factory
        address tokenAddress = factory.deployInscription("MYTOKEN", 1000 * 10**18, 10 * 10**18);
        console.log("Deployed InscriptionToken at:", tokenAddress);

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
