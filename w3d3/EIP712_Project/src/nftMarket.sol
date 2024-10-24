// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is Ownable, EIP712 {
    using ECDSA for bytes32;

    IERC20 public token;  // ERC20 token used for payments
    IERC721 public nftContract;  // ERC721 contract for NFTs
    address public whitelistSigner;  // Address of the whitelist signer

    struct Listing {
        address seller;
        uint256 price;
    }

    // Mapping from tokenId to Listing information
    mapping(uint256 => Listing) public listings;

    // Mapping to track nonces for preventing replay attacks
    mapping(address => uint256) public nonces;

    // Events for listing and purchasing NFTs
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTBought(uint256 indexed tokenId, address indexed buyer, uint256 price);

    // Constructor to initialize NFTMarket with token and NFT contract addresses and whitelist signer
    constructor(address _token, address _nftContract, address admin_address, address _whitelistSigner) 
        Ownable(admin_address) 
        EIP712("NFTMarket", "1.0") 
    {
        token = IERC20(_token);
        nftContract = IERC721(_nftContract);
        whitelistSigner = _whitelistSigner;
    }

    // Helper function to expose _hashTypedDataV4 for tests
    function hashTypedData(bytes32 structHash) external view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }

    // Function to list an NFT for sale
    function list(uint256 tokenId, uint256 price) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You are not the owner");
        require(nftContract.isApprovedForAll(msg.sender, address(this)) || nftContract.getApproved(tokenId) == address(this), "NFT not approved for marketplace");

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price
        });

        emit NFTListed(tokenId, msg.sender, price);
    }

    // Function to allow users to buy an NFT using an off-chain permit
    function permitBuy(uint256 tokenId, uint256 price, bytes memory signature) external payable {
        // Get the nonce for the buyer
        uint256 nonce = nonces[msg.sender];
        
        // Construct the struct hash
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address buyer,uint256 tokenId,uint256 price,uint256 nonce)"),
                msg.sender,   // Address of the buyer
                tokenId,      // NFT tokenId
                price,        // Price for the NFT
                nonce
            )
        );

        // Compute the digest using the EIP712 domain separator
        bytes32 digest = _hashTypedDataV4(structHash);

        // Split the signature into r, s, and v
        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature);

        // Recover the signer from the signature
        address recoveredSigner = ECDSA.recover(digest, v, r, s);

        // Verify that the recovered signer is the valid whitelist signer
        require(recoveredSigner == whitelistSigner, "Invalid signature");

        // Update the nonce to prevent replay attacks
        nonces[msg.sender]++;

        // Proceed with the NFT purchase
        _buyNFT(tokenId, price);
    }

    // Function for anyone to buy an NFT without whitelist verification
    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];

        // Check if the NFT is listed and if the buyer has enough balance
        require(listing.price > 0, "NFT not listed");
        require(token.balanceOf(msg.sender) >= listing.price, "Insufficient balance");

        // Proceed with the purchase using internal logic
        _buyNFT(tokenId, listing.price);
    }

    // Internal function to handle the purchase of NFTs
    function _buyNFT(uint256 tokenId, uint256 price) internal {
        Listing memory listing = listings[tokenId];

        // Ensure the NFT is listed and the price matches
        require(listing.price > 0, "NFT not listed");
        require(token.balanceOf(msg.sender) >= price, "Insufficient balance");
        require(listing.price == price, "Incorrect price");

        // Transfer ERC20 tokens from buyer to seller
        require(token.transferFrom(msg.sender, listing.seller, price), "Token transfer failed");

        // Transfer the NFT from the seller to the buyer
        nftContract.safeTransferFrom(listing.seller, msg.sender, tokenId);

        // Remove the listing after the purchase
        delete listings[tokenId];

        emit NFTBought(tokenId, msg.sender, price);
    }

    // **New: Getter function to retrieve the listing details for a specific tokenId**
    function getListing(uint256 tokenId) external view returns (address seller, uint256 price) {
        Listing memory listing = listings[tokenId];
        return (listing.seller, listing.price);
    }

    // Helper function to split signature into r, s, and v
    function _splitSignature(bytes memory sig)
        internal
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Return r, s and v
        return (r, s, v);
    }
}
