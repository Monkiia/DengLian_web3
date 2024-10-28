// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/InscriptionFactory.sol";
import "forge-std/console.sol";

contract InscriptionFactoryTest is Test {
    InscriptionFactory factory;

    // Define test parameters
    string constant SYMBOL = "TEST";
    uint constant TOTAL_SUPPLY = 1000 * 10**18;
    uint constant PER_MINT = 100 * 10**18;

    function setUp() public {
        factory = new InscriptionFactory();
    }

    function testDeployInscription() public {
        // Deploy a new token and verify the token address is valid
         
        address tokenAddr = factory.deployInscription(SYMBOL, TOTAL_SUPPLY, PER_MINT);
        assertTrue(tokenAddr != address(0), "Token address should not be zero");

        // Verify that the token information matches what was set during deployment
         
        (address deployedAddr, uint totalSupply, uint perMint) = factory.tokens(tokenAddr);
        assertEq(deployedAddr, tokenAddr, "Deployed address should match the token address");
        assertEq(totalSupply, TOTAL_SUPPLY, "Total supply should match");
        assertEq(perMint, PER_MINT, "Per mint should match");
    }

    function testMintInscription() public {
         
        // Deploy a token
        address tokenAddr = factory.deployInscription(SYMBOL, TOTAL_SUPPLY, PER_MINT);
        InscriptionToken token = InscriptionToken(tokenAddr);

        // Check initial balance
        uint initialBalance = token.balanceOf(address(this));
        assertEq(initialBalance, 0, "Initial balance should be zero");

        // Mint tokens and verify the balance increase
         
        factory.mintInscription(tokenAddr);
        uint balanceAfterMint = token.balanceOf(address(this));
        assertEq(balanceAfterMint, PER_MINT, "Balance should match per mint amount after mint");

        // Mint again and check the balance update
         
        factory.mintInscription(tokenAddr);
        uint balanceAfterSecondMint = token.balanceOf(address(this));
        assertEq(balanceAfterSecondMint, PER_MINT * 2, "Balance should match twice the per mint amount after second mint");
    }

    function testMintExceedsTotalSupply() public {
         
        // Deploy a token with a total supply limit smaller than two mints
        uint smallTotalSupply = PER_MINT + 10**18; // Just slightly over 1 mint
        address tokenAddr = factory.deployInscription(SYMBOL, smallTotalSupply, PER_MINT);
        
        // Mint once successfully
         
        factory.mintInscription(tokenAddr);
        
        // Attempt a second mint; should revert as it would exceed total supply
         
        vm.expectRevert("Exceeds total supply limit");
        factory.mintInscription(tokenAddr);
    }
}
