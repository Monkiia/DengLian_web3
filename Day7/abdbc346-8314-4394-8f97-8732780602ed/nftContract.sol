// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public currentTokenId;

    // 构造函数初始化 ERC721 和 Ownable 并指定初始所有者
    constructor(address initialOwner) ERC721("DLMNFT", "DLMNFT") Ownable(initialOwner) {}

    // 仅限合约所有者能够调用的铸造函数
    function mintTo(address recipient) public onlyOwner {
        uint256 newTokenId = currentTokenId;
        _safeMint(recipient, newTokenId);
        currentTokenId++;
    }

    // 简单起见，现在我们所有的都指向一个metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return "ipfs://QmY9BmyFabvjXbyac7ucwK1Y75FygGzmBpU12YqRtTgWYF";
    }

}

