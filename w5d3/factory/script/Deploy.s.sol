// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/InscriptionToken.sol";
import "../src/InscriptionFactoryV1.sol";
import "../src/InscriptionFactoryV2.sol";
import "../src/UUPSProxy.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER_ADDRESS");

        // Pre-compute the addresses for console output
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deploying contracts with address:", deployer);
        console.log("Setting owner to:", owner);
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation contracts
        InscriptionToken implementationToken = new InscriptionToken();
        console.log("InscriptionToken implementation deployed at:", address(implementationToken));

        // Deploy factory implementations
        InscriptionFactoryV1 factoryV1Implementation = new InscriptionFactoryV1();
        console.log("FactoryV1 implementation deployed at:", address(factoryV1Implementation));

        InscriptionFactoryV2 factoryV2Implementation = new InscriptionFactoryV2();
        console.log("FactoryV2 implementation deployed at:", address(factoryV2Implementation));

        // Deploy proxy with V1 implementation
        UUPSProxy proxy = new UUPSProxy(address(factoryV1Implementation));
        console.log("Proxy deployed at:", address(proxy));

        // Initialize proxy with owner
        InscriptionFactoryV1(address(proxy)).initialize(owner);
        console.log("Proxy initialized with owner:", owner);

        // Verify storage slots after deployment
        bytes32 implSlot = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
        bytes32 ownerSlot = bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1);
        
        address storedImpl = address(uint160(uint256(vm.load(address(proxy), implSlot))));
        address storedOwner = address(uint160(uint256(vm.load(address(proxy), ownerSlot))));
        
        console.log("\n=== Storage Verification ===");
        console.log("Implementation slot:", vm.toString(implSlot));
        console.log("Owner slot:", vm.toString(ownerSlot));
        console.log("Stored implementation:", storedImpl);
        console.log("Stored owner:", storedOwner);

        require(storedImpl == address(factoryV1Implementation), "Implementation not set correctly");
        require(storedOwner == deployer, "Owner not set correctly");

        vm.stopBroadcast();

        console.log("\n=== Deployment Summary ===");
        console.log("Network:", block.chainid);
        console.log("Inscription Token Implementation:", address(implementationToken));
        console.log("Factory V1 Implementation:", address(factoryV1Implementation));
        console.log("Factory V2 Implementation:", address(factoryV2Implementation));
        console.log("Proxy:", address(proxy));
        console.log("Owner:", owner);
        console.log("Deployer:", deployer);

        console.log("\n=== For .env File ===");
        console.log("PROXY_ADDRESS=", address(proxy));
        console.log("TOKEN_IMPLEMENTATION_ADDRESS=", address(implementationToken));
        console.log("FACTORY_V2_ADDRESS=", address(factoryV2Implementation));
    }
}