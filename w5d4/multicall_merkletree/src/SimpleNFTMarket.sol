// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

contract SimpleNFTMarket {
    bytes32 public merkleRoot;
    IERC721 public nft;

    struct ListedNFT {
        uint256 price; // NFT的价格
        bool isListed; // 是否已上架
    }

    mapping(uint256 => ListedNFT) public listedNFTs; // 记录已上架的NFT
    mapping(address => bool) public hasClaimed;      // 记录已领取的用户

    constructor(bytes32 _merkleRoot, address _nft) {
        merkleRoot = _merkleRoot;
        nft = IERC721(_nft);
    }

    // 列出NFT在市场上销售
    function listNFT(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "NFT must be owned by the caller");
        
        // 设置NFT的价格和状态
        listedNFTs[tokenId] = ListedNFT(price, true);
    }

    // 检查地址是否在白名单中
    function verifyWhiteListedOrNot(address _address, bytes32[] calldata proof) external view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_address));
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    // 用户通过permit授权Token
    function permitPrePay(
        IERC20Permit token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        token.permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    // claimNFT: 验证白名单并完成购买
    function claimNFT(
        IERC20 token,
        uint256 tokenId,
        bytes32[] calldata proof
    ) external {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(listedNFTs[tokenId].isListed, "NFT not listed for sale");

        // 验证白名单
        // console.log("msg.sender: %s", msg.sender);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Not in whitelist");

        // 获取NFT价格并检查授权
        uint256 price = listedNFTs[tokenId].price / 2;
        address nftCurrentOwner = nft.ownerOf(tokenId);
        require(token.allowance(msg.sender, address(this)) >= price, "Insufficient allowance");

        // 转移Token到NFT当前所有者
        require(token.transferFrom(msg.sender, nftCurrentOwner, price), "Token transfer failed");

        // 将NFT转移给用户
        nft.safeTransferFrom(nftCurrentOwner, msg.sender, tokenId);

        // 标记用户已领取
        hasClaimed[msg.sender] = true;

        // 更新NFT状态为未上架
        listedNFTs[tokenId].isListed = false;
    }

    // 设置新的Merkle树根节点
    function setMerkleRoot(bytes32 _merkleRoot) external {
        merkleRoot = _merkleRoot;
    }


    // 多重调用（multicall）函数，使用delegatecall执行多个方法
    function multicall(bytes[] calldata data) external {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, _getRevertMsg(result));
        }
    }

    // Helper function to decode and return the revert message
    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        if (_returnData.length < 68) return "Transaction reverted silently";
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }
}
