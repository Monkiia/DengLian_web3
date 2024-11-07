// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/InscriptionToken.sol";
import "../src/InscriptionFactoryV1.sol";
import "../src/InscriptionFactoryV2.sol";
import "../src/UUPSProxy.sol";

contract UpgradeToV2Script is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address implementationToken = vm.envAddress("TOKEN_IMPLEMENTATION_ADDRESS");
        address factoryV2Implementation = vm.envAddress("FACTORY_V2_ADDRESS");

        address deployer = vm.addr(deployerPrivateKey);
        console.log("Upgrading contracts with address:", deployer);
        console.log("Proxy address:", proxy);
        console.log("V2 implementation:", factoryV2Implementation);
        console.log("Token implementation:", implementationToken);

        // Read implementation directly from storage
        bytes32 implementationSlot = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
        address currentImpl = address(uint160(uint256(vm.load(proxy, implementationSlot))));
        console.log("Current implementation:", currentImpl);
        
        // Read owner directly from storage
        bytes32 ownerSlot = bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1);
        address currentOwner = address(uint160(uint256(vm.load(proxy, ownerSlot))));
        console.log("Current owner from storage:", currentOwner);

        require(currentOwner == deployer, "Deployer is not proxy owner");

        vm.startBroadcast(deployerPrivateKey);

        // Upgrade to V2
        UUPSProxy(payable(proxy)).upgradeTo(factoryV2Implementation);
        console.log("Proxy upgraded to V2 implementation");

        // Initialize V2 implementation
        bytes memory initData = abi.encodeWithSignature("initialize(address)", deployer);
        (bool success,) = proxy.call(initData);
        require(success, "V2 initialization failed");
        console.log("V2 implementation initialized");

        // Set token implementation
        InscriptionFactoryV2(proxy).setTokenImplementation(implementationToken);
        console.log("Token implementation set");

        vm.stopBroadcast();

        // Verify upgrade
        address newImpl = address(uint160(uint256(vm.load(proxy, implementationSlot))));
        require(newImpl == factoryV2Implementation, "Upgrade verification failed");

        console.log("\n=== Upgrade Summary ===");
        console.log("Network:", block.chainid);
        console.log("Proxy Address:", proxy);
        console.log("Previous Implementation:", currentImpl);
        console.log("New Implementation (V2):", newImpl);
        console.log("Token Implementation:", implementationToken);
    }
}