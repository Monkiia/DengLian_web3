// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleNFT is ERC721, Ownable {
    uint256 public nextTokenId; // 下一个NFT的tokenId

    constructor() ERC721("SimpleNFT", "SNFT") Ownable(msg.sender) {}

    // 铸造NFT，只有合约拥有者可以调用
    function mint(address to) external onlyOwner {
        _safeMint(to, nextTokenId);
        nextTokenId++;
    }
}
