// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OSNFT is ERC721("OpenSpaceNFT", "OSNFT") {
    address public owner;

    constructor() {
        owner = msg.sender;
        mint(0);
        mint(1);
        mint(2);
    }

    function mint(uint256 tokenId) public {
        require(tokenId < 2024, "tokenId must be less than 2024");
        _safeMint(msg.sender, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        // example: https://data.debox.pro/dgs/meta/1
        return "https://data.debox.pro/dgs/meta/";
    }
}