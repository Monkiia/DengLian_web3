// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./InscriptionToken.sol";

contract InscriptionFactoryV1 is Initializable, OwnableUpgradeable {
    event InscriptionDeployed(address indexed token, string name, string symbol, uint256 totalSupply);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
    }

    function deployInscription(
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) external onlyOwner returns (address) {
        InscriptionToken token = new InscriptionToken();
        token.initialize(name, symbol, totalSupply);
        emit InscriptionDeployed(address(token), name, symbol, totalSupply);
        return address(token);
    }
}