// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract InscriptionToken is Initializable, ERC20Upgradeable {
    uint256 public totalSupply_;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // Do not disable initializers to allow proxy initialization
    }

    function initialize(string memory name, string memory symbol, uint256 _totalSupply) external initializer {
        __ERC20_init(name, symbol);
        totalSupply_ = _totalSupply;
        _mint(msg.sender, totalSupply_);
    }

    function mint(address to, uint256 amount) external {
        require(totalSupply_ >= amount, "Exceeds total supply");
        totalSupply_ -= amount;
        _mint(to, amount);
    }
}