// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/InscriptionToken.sol";
import "../src/InscriptionFactoryV1.sol";
import "../src/InscriptionFactoryV2.sol";
import "../src/UUPSProxy.sol";

contract InscriptionTest is Test {
    InscriptionToken public implementationToken;
    InscriptionFactoryV1 public factoryV1Implementation;
    InscriptionFactoryV2 public factoryV2Implementation;
    UUPSProxy public factoryProxy;
    
    address public owner;
    address public user1;
    address public user2;
    
    event InscriptionDeployed(address indexed token, string name, string symbol, uint256 totalSupply);
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy implementation contracts
        implementationToken = new InscriptionToken();
        
        // Deploy factory implementations
        factoryV1Implementation = new InscriptionFactoryV1();
        factoryV2Implementation = new InscriptionFactoryV2();
        
        // Deploy proxy with V1 implementation
        factoryProxy = new UUPSProxy(address(factoryV1Implementation));
        
        // Initialize proxy with owner
        bytes memory initData = abi.encodeWithSignature("initialize(address)", owner);
        (bool success,) = address(factoryProxy).call(initData);
        require(success, "Proxy initialization failed");
        
        // Fund test users
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }
    
    function testFactoryUpgradeV1ToV2() public {
        // Test V1 functionality before upgrade
        InscriptionFactoryV1 proxyAsV1 = InscriptionFactoryV1(address(factoryProxy));
        
        // Deploy token using V1
        string memory nameV1 = "Test Token V1";
        string memory symbolV1 = "TSTV1";
        uint256 totalSupplyV1 = 1000000 * 10**18;
        
        address predictedTokenV1 = vm.computeCreateAddress(
            address(factoryProxy),
            vm.getNonce(address(factoryProxy))
        );
        
        vm.expectEmit(true, false, false, true);
        emit InscriptionDeployed(predictedTokenV1, nameV1, symbolV1, totalSupplyV1);
        
        address tokenV1 = proxyAsV1.deployInscription(nameV1, symbolV1, totalSupplyV1);
        InscriptionToken deployedTokenV1 = InscriptionToken(tokenV1);
        
        // Verify V1 deployment
        assertEq(deployedTokenV1.name(), nameV1);
        assertEq(deployedTokenV1.symbol(), symbolV1);
        assertEq(deployedTokenV1.totalSupply(), totalSupplyV1);
        assertEq(deployedTokenV1.balanceOf(address(factoryProxy)), totalSupplyV1);
        
        // Upgrade to V2
        factoryProxy.upgradeTo(address(factoryV2Implementation));
        
        // Cast proxy to V2
        InscriptionFactoryV2 proxyAsV2 = InscriptionFactoryV2(address(factoryProxy));
        
        // Set token implementation
        proxyAsV2.setTokenImplementation(address(implementationToken));
        
        // Test V2 specific functionality
        string memory nameV2 = "Test Token V2";
        string memory symbolV2 = "TSTV2";
        uint256 totalSupplyV2 = 2000000 * 10**18;
        
        // Get predicted clone address
        address predictedTokenV2 = proxyAsV2.predictDeterministicAddress(
            nameV2,
            symbolV2,
            totalSupplyV2
        );
        
        vm.expectEmit(true, false, false, true);
        emit InscriptionDeployed(predictedTokenV2, nameV2, symbolV2, totalSupplyV2);
        
        address tokenV2 = proxyAsV2.deployInscription(nameV2, symbolV2, totalSupplyV2);
        InscriptionToken deployedTokenV2 = InscriptionToken(tokenV2);
        
        // Verify addresses match
        assertEq(tokenV2, predictedTokenV2, "Deployed address should match predicted address");
        
        // Verify V2 deployment
        assertEq(deployedTokenV2.name(), nameV2);
        assertEq(deployedTokenV2.symbol(), symbolV2);
        assertEq(deployedTokenV2.totalSupply(), totalSupplyV2);
        assertEq(deployedTokenV2.balanceOf(address(factoryProxy)), totalSupplyV2);
        
        // Test V2's mint function
        uint256 mintAmount = 100 * 10**18;
        vm.prank(user1);
        proxyAsV2.mintInscription(tokenV2, mintAmount);
        
        assertEq(deployedTokenV2.balanceOf(user1), mintAmount);
    }
    
    function testMintingLimits() public {
        // Upgrade to V2
        factoryProxy.upgradeTo(address(factoryV2Implementation));
        InscriptionFactoryV2 proxyAsV2 = InscriptionFactoryV2(address(factoryProxy));
        
        // Set token implementation
        proxyAsV2.setTokenImplementation(address(implementationToken));
        
        address token = proxyAsV2.deployInscription("Test", "TST", 1000 * 10**18);
        
        // Should be able to mint up to total supply
        vm.prank(user1);
        proxyAsV2.mintInscription(token, 500 * 10**18);
        
        // Should revert when trying to mint more than remaining supply
        vm.expectRevert("Exceeds total supply");
        vm.prank(user1);
        proxyAsV2.mintInscription(token, 501 * 10**18);
    }
}