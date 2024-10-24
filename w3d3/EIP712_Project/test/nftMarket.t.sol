// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../src/nftContract.sol";  // Mock ERC721 contract for testing
import "../src/Token.sol";  // Mock ERC20 contract for testing

contract NFTMarketTest is Test {
    NFTMarket public market;
    MyNFT public nftContract;
    MyPermitToken public token;
    address public whitelistSigner;
    address buyer = address(0x123);
    address seller = address(0x456);
    uint256 tokenId = 1;
    uint256 price = 1000 ether;
    uint256 deadline;
    uint256 whitelistSignerPrivateKey = 0xABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890; // Example private key

    function setUp() public {
        // Compute whitelist signer address from the private key
        whitelistSigner = vm.addr(whitelistSignerPrivateKey);

        // Deploy mock ERC721 and ERC20 contracts
        nftContract = new MyNFT(address(this));  // Owner of the contract is the test contract
        token = new MyPermitToken();

        // Deploy the NFTMarket contract
        market = new NFTMarket(address(token), address(nftContract), address(this), whitelistSigner);

        nftContract.mintTo(seller);  // Mint tokenId 1 to seller
        nftContract.mintTo(seller);  // Mint tokenId 1 to seller

        // Mint NFT to the seller
        vm.startPrank(seller);  // Start acting as the seller
        // Approve the market contract to transfer the NFT on behalf of the seller
        nftContract.approve(address(market), tokenId);
        vm.stopPrank();  // Stop acting as the seller

        // Mint tokens to the buyer and approve the market
        token.transfer(buyer, 1000 * 10 ** token.decimals());
        vm.startPrank(buyer);  // Start acting as the buyer
        token.approve(address(market), price);
        vm.stopPrank();  // Stop acting as the buyer
    }

    function testPermitBuy() public {
        // Buyer nonce
        uint256 nonce = market.nonces(buyer);

        // Construct the permit hash for signing
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address buyer,uint256 tokenId,uint256 price,uint256 nonce)"),
                buyer,
                tokenId,
                price,
                nonce
            )
        );

        // Use the helper function to get the EIP712 digest
        bytes32 digest = market.hashTypedData(structHash);

        // Sign the digest with the whitelistSigner's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(whitelistSignerPrivateKey, digest);

        // Combine the signature components into a single bytes array
        bytes memory signature = abi.encodePacked(r, s, v);

        // List the NFT first
        vm.startPrank(seller);
        market.list(tokenId, price);  // List the NFT for sale
        vm.stopPrank();

        // Execute permitBuy with the signature
        vm.startPrank(buyer);
        market.permitBuy(tokenId, price, signature);
        vm.stopPrank();

        // Check if the buyer now owns the NFT
        assertEq(nftContract.ownerOf(tokenId), buyer);
    }

    function testPermitBuy_wrongsig() public {
        // Buyer nonce
        uint256 nonce = market.nonces(buyer);

        // Construct the permit hash for signing
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address buyer,uint256 tokenId,uint256 price,uint256 nonce)"),
                buyer,
                tokenId,
                price,
                nonce
            )
        );

        // Use the helper function to get the EIP712 digest
        bytes32 digest = market.hashTypedData(structHash);

        // Sign the digest with the whitelistSigner's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(whitelistSignerPrivateKey, digest);

        // Combine the signature components into a single bytes array
        // Make the signature wrong by adding 1 to v
        bytes memory signature = abi.encodePacked(r, s, v + 1);

        // List the NFT first
        vm.startPrank(seller);
        market.list(tokenId, price);  // List the NFT for sale
        vm.stopPrank();

        // Expect the transaction to revert as we have wrong sig
        vm.expectRevert();
        // Execute permitBuy with the invalid signature
        vm.startPrank(buyer);
        market.permitBuy(tokenId, price, signature);
        vm.stopPrank();
    }
    
    // Test if a bad user intercepts the signature of another user, it will still fail
    function testPermitBuy_badUser() public {
        // Buyer nonce
        uint256 nonce = market.nonces(buyer);

        // Construct the permit hash for signing
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address buyer,uint256 tokenId,uint256 price,uint256 nonce)"),
                buyer,
                tokenId,
                price,
                nonce
            )
        );

        // Use the helper function to get the EIP712 digest
        bytes32 digest = market.hashTypedData(structHash);

        // Sign the digest with the whitelistSigner's private key (valid for `buyer`)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(whitelistSignerPrivateKey, digest);

        // Combine the signature components into a single bytes array
        bytes memory signature = abi.encodePacked(r, s, v);

        // List the NFT first
        vm.startPrank(seller);
        market.list(tokenId, price);  // List the NFT for sale
        vm.stopPrank();

        // Now simulate a bad user trying to use `buyer`'s signature
        address badUser = address(0x789);  // Simulating a malicious user

        // Expect the transaction to revert since `badUser` is not the `buyer`
        vm.expectRevert("Invalid signature");
        // Attempt permitBuy with the intercepted signature as `badUser`
        vm.startPrank(badUser);
        market.permitBuy(tokenId, price, signature);  // Should revert
        vm.stopPrank();
    }
}
