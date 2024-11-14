// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RNT is ERC20 {
    constructor(uint256 initialSupply) ERC20("RNT Token", "RNT") {
        _mint(msg.sender, initialSupply);
    }
}
