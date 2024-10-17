// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";  // Foundry's testing library
import {NFTMarket} from "../src/nftMarket.sol"; // Your NFTMarket contract
import "../src/tokenbankv2.sol"; // Custom ERC20 token for payments (DLCCoinV2)
import "../src/nftContract.sol";     // Custom NFT contract

contract NFTMarketTest is Test {
    NFTMarket public nftMarket;
    DLCCoinV2 public DLCtoken;
    MyNFT public myNFT;
    address public seller;
    address public buyer;

    function setUp() public {
        // Setup seller and buyer addresses
        seller = address(0x1);
        buyer = address(0x2);

        // Fund seller and buyer with some ETH for transaction costs
        vm.deal(seller, 1 ether);
        vm.deal(buyer, 1 ether);

        // Deploy the custom ERC20 token (DLCtoken)
        DLCtoken = new DLCCoinV2();

        // Deploy the NFT contract (myNFT) and assign ownership to this contract
        myNFT = new MyNFT(address(this));

        // Deploy the NFT marketplace contract
        nftMarket = new NFTMarket(address(DLCtoken), address(myNFT), address(this));

        // Transfer some tokens to the buyer to be used for purchasing NFTs
        DLCtoken.transfer(buyer, 500 * 10 ** 18);

        // Mint an NFT to the seller
        myNFT.mintTo(seller); // tokenID = 0
        myNFT.mintTo(seller); // tokenID = 1
    }

    // Test listing an NFT on the marketplace
    function testListNFT() public {
        // Seller approves the marketplace to transfer their NFT
        vm.startPrank(seller); // Ensure that the following actions are executed as `seller`
        myNFT.approve(address(nftMarket), 1); // Approve the marketplace for the NFT with tokenId 1
        nftMarket.list(1, 100 * 10 ** 18); // List the NFT with a price of 100 DLC tokens

        // Fetch the listing details from the marketplace
        (address listedSeller, uint256 price) = nftMarket.getListing(1);
        
        // Verify that the listing details are correct
        assertEq(listedSeller, seller);
        assertEq(price, 100 * 10 ** 18);
        
        vm.stopPrank();
    }

    // Test purchasing an NFT from the marketplace using ERC20 tokens
    function testBuyNFT() public {
        // First, the seller lists their NFT for sale
        vm.startPrank(seller);
        myNFT.approve(address(nftMarket), 1); // Approve the marketplace to transfer the NFT
        nftMarket.list(1, 100 * 10 ** 18); // List the NFT for 100 DLC tokens
        vm.stopPrank();

        // Buyer approves the marketplace to use their DLC tokens
        vm.startPrank(buyer);
        DLCtoken.approve(address(nftMarket), 100 * 10 ** 18); // Approve marketplace to use 100 DLC tokens
        nftMarket.buyNFT(1); // Call the buyNFT function to purchase the NFT with tokenId 1

        // Verify that the NFT ownership has been transferred to the buyer
        assertEq(myNFT.ownerOf(1), buyer);

        // Verify that the seller received the correct amount of DLC tokens
        uint256 sellerBalance = DLCtoken.balanceOf(seller);
        assertEq(sellerBalance, 100 * 10 ** 18);

        // Ensure that the listing is removed after the purchase
        (address listedSeller, uint256 price) = nftMarket.getListing(1);
        assertEq(listedSeller, address(0)); // Listing should no longer exist
        assertEq(price, 0);
        
        vm.stopPrank();
    }

    // Test use Transfer to buy the NFT
     function testTransferToBuyNFT() public {
        // First, the seller lists their NFT for sale
        vm.startPrank(seller);
        myNFT.approve(address(nftMarket), 0); // Approve the marketplace to transfer the NFT
        nftMarket.list(0, 100 * 10 ** 18); // List the NFT for 100 DLC tokens
        vm.stopPrank();

        // Buyer approves the marketplace to use their DLC tokens
        vm.startPrank(buyer);
        DLCtoken.transfer(address(nftMarket), 100 * 10 ** 18);

        // Verify that the NFT ownership has been transferred to the buyer
        assertEq(myNFT.ownerOf(0), buyer);

        // Verify that the seller received the correct amount of DLC tokens
        uint256 sellerBalance = DLCtoken.balanceOf(seller);
        assertEq(sellerBalance, 100 * 10 ** 18);

        // Ensure that the listing is removed after the purchase
        (address listedSeller, uint256 price) = nftMarket.getListing(1);
        assertEq(listedSeller, address(0)); // Listing should no longer exist
        assertEq(price, 0);
        
        vm.stopPrank();
     }

    
    // Test transfer with more money than required
         function testTransferMoreMoneyToBuyNFT() public {
        // First, the seller lists their NFT for sale
        vm.startPrank(seller);
        myNFT.approve(address(nftMarket), 0); // Approve the marketplace to transfer the NFT
        nftMarket.list(0, 100 * 10 ** 18); // List the NFT for 100 DLC tokens
        vm.stopPrank();

        // Buyer approves the marketplace to use their DLC tokens
        vm.startPrank(buyer);
        DLCtoken.transfer(address(nftMarket), 200 * 10 ** 18);

        // Verify that the NFT ownership has been transferred to the buyer
        assertEq(myNFT.ownerOf(0), buyer);

        // Verify that the seller received the correct amount of DLC tokens
        uint256 sellerBalance = DLCtoken.balanceOf(seller);
        assertEq(sellerBalance, 100 * 10 ** 18);

        // Ensure that the listing is removed after the purchase
        (address listedSeller, uint256 price) = nftMarket.getListing(1);
        assertEq(listedSeller, address(0)); // Listing should no longer exist
        assertEq(price, 0);
        
        vm.stopPrank();
     }


    // Test that only the owner can approve their NFT
    function testOnlyOwnerCanApproveNFT() public {
        // Another address (not the owner) tries to list the NFT
        vm.startPrank(buyer);
        vm.expectRevert(); // Expect revert due to lack of ownership
        myNFT.approve(address(nftMarket), 1); // Attempt to approve NFT transfer
        vm.stopPrank();
    }    

    // Test that only the owner can list their NFT
    function testOnlyOwnerCanListNFT() public {
        // Another address (not the owner) tries to list the NFT
        vm.startPrank(buyer);
        // myNFT.approve(address(nftMarket), 1); // Attempt to approve NFT transfer
        vm.expectRevert("You are not the owner"); // Expect revert due to lack of ownership
        nftMarket.list(1, 100 * 10 ** 18); // Try listing NFT with tokenId 1
        vm.stopPrank();
    }

    // Test that insufficient funds prevent purchase
    function testInsufficientFunds() public {
        // Seller lists the NFT
        vm.startPrank(seller);
        myNFT.approve(address(nftMarket), 1);
        nftMarket.list(1, 200 * 10 ** 18); // Listing NFT for 200 DLC tokens
        vm.stopPrank();

        // Buyer approves less DLC tokens than required
        vm.startPrank(buyer);
        DLCtoken.approve(address(nftMarket), 100 * 10 ** 18); // Only approving 100 DLC tokens
        vm.expectRevert();
        nftMarket.buyNFT(1); // Try to buy NFT with insufficient funds
        vm.stopPrank();
    }

        // --- Fuzz Testing for Random Prices and Random Buyer ---
    function testFuzzListingAndBuying(uint256 price) public {
        // We limit the price to between 0.01 and 10000 DLC tokens (scaled by 1e18 for decimals)
        price = bound(price, 0.01 * 10 ** 18, 10000 * 10 ** 18);

        // Setup a random buyer address
        address randomBuyer = vm.addr(uint256(keccak256(abi.encodePacked(block.timestamp))));

        // Fund the random buyer with some ETH and tokens for transaction costs
        vm.deal(randomBuyer, 1 ether);
        DLCtoken.transfer(randomBuyer, price);

        // Seller lists the NFT at the random price
        vm.startPrank(seller);
        myNFT.approve(address(nftMarket), 0); // Approve marketplace to transfer NFT
        nftMarket.list(0, price); // List the NFT for `price` DLC tokens
        vm.stopPrank();

        // Buyer buys the NFT
        vm.startPrank(randomBuyer);
        DLCtoken.approve(address(nftMarket), price);
        nftMarket.buyNFT(0); // Call the buyNFT function to purchase the NFT with tokenId 0

        // Verify that the random buyer now owns the NFT
        assertEq(myNFT.ownerOf(0), randomBuyer);

        // Ensure that the listing is removed after the purchase
        (address listedSeller, uint256 listedPrice) = nftMarket.getListing(0);
        assertEq(listedSeller, address(0)); // Listing should no longer exist
        assertEq(listedPrice, 0);

        vm.stopPrank();
    }

    // --- Immutability Test for Token Holding ---
    function testMarketContractDoesNotHoldTokens() public {
        // Seller lists the NFT for sale
        vm.startPrank(seller);
        myNFT.approve(address(nftMarket), 1); // Approve the marketplace for the NFT with tokenId 1
        nftMarket.list(1, 100 * 10 ** 18); // List the NFT for 100 DLC tokens
        vm.stopPrank();

        // Buyer approves and buys the NFT
        vm.startPrank(buyer);
        DLCtoken.approve(address(nftMarket), 100 * 10 ** 18);
        nftMarket.buyNFT(1); // Buyer purchases the NFT
        vm.stopPrank();

        // Assert that the marketplace does not hold any DLC tokens
        uint256 marketBalance = DLCtoken.balanceOf(address(nftMarket));
        assertEq(marketBalance, 0); // The contract should not hold any tokens
    }

}
