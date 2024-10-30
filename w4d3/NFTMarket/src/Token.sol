// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyFirstToken is ERC20 {
    constructor() ERC20("DLC", "DLC") {
        _mint(msg.sender, 1e9 * 1e18); // 1 billion
    }
}