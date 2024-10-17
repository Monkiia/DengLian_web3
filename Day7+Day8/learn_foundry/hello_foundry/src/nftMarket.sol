// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Receiver {
    function tokensReceived(address from, uint256 amount, bytes calldata data) external payable;
}

contract NFTMarket is Ownable, IERC20Receiver {
    IERC20 public token;  // 自定义的 ERC20 代币，用于支付
    IERC721 public nftContract;  // NFT 合约

    struct Listing {
        address seller;
        uint256 price;
    }

    // tokenId 到 Listing 的映射
    mapping(uint256 => Listing) public listings;

    // 事件
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTBought(uint256 indexed tokenId, address indexed buyer, uint256 price);

    constructor(address _token, address _nftContract, address admin_address) Ownable(admin_address) {
        token = IERC20(_token);  // 设定 ERC20 代币的合约地址
        nftContract = IERC721(_nftContract);  // 设定 ERC721 NFT 的合约地址
    }

    // 上架 NFT 并设置价格，NFT 持有者调用此函数
    function list(uint256 tokenId, uint256 price) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You are not the owner");
        require(nftContract.isApprovedForAll(msg.sender, address(this)) || nftContract.getApproved(tokenId) == address(this), "NFT not approved for marketplace");

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price
        });

        emit NFTListed(tokenId, msg.sender, price);
    }

    function tokensReceived(address from, uint256 amount, bytes calldata data) external payable{
        // 只有token 合约地址才可以call 这个回调函数
        require(msg.sender == address(token), "Only token contract can call this callback function");

        // 解码 data 中的数据
        // uint256 tokenId = abi.decode(data, (uint256));
        // For simplity, we hardcode the data to be bytes(0), thus tokenId being 0
        uint tokenId = 0;
        address buyer = from;
        Listing memory listing = listings[tokenId];

        require(listing.price > 0, "NFT not listed");
        require(amount >= listing.price, "Insufficient amount");

        // 将 NFT 转移给买家
        nftContract.safeTransferFrom(listing.seller, buyer, tokenId);
        // 给 Seller 打钱
        token.transfer(listing.seller, listing.price);
        if (listing.price > amount) {
            token.transfer(buyer, listing.price - amount);
        }
        // 移除 listing
        delete listings[tokenId];

        emit NFTBought(tokenId, buyer, listing.price);
    }

    function getListing(uint256 tokenId) external view returns (address, uint256) {
        Listing memory listing = listings[tokenId];
        return (listing.seller, listing.price);
    }

    // ERC20 的接收者方法，完成 NFT 的购买
    function payment_process(address buyer, uint256 tokenId) internal {
        Listing memory listing = listings[tokenId];

        require(listing.price > 0, "NFT not listed");
        require(token.balanceOf(buyer) >= listing.price, "Insufficient balance");

        // 从买家转账给卖家
        require(token.transferFrom(buyer, listing.seller, listing.price), "Token transfer failed");

        // 将 NFT 转移给买家
        nftContract.safeTransferFrom(listing.seller, buyer, tokenId);

        // 移除 listing
        delete listings[tokenId];

        emit NFTBought(tokenId, buyer, listing.price);
    }

    // buyNFT 方法，通过 tokensReceived 实现 NFT 购买功能
    function buyNFT(uint256 tokenId) external {
        payment_process(msg.sender, tokenId);
    }


}

