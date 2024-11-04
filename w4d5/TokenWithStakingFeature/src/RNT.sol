// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RNT is ERC20, Ownable {
    constructor() ERC20("Mock RNT Token", "RNT") Ownable(msg.sender) {}

    // Only the owner (deployer) can mint tokens for testing purposes
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
