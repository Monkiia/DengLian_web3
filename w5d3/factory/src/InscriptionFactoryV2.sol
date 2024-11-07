// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./InscriptionToken.sol";

contract InscriptionFactoryV2 is Initializable, OwnableUpgradeable {
    using Clones for address;

    event InscriptionDeployed(address indexed token, string name, string symbol, uint256 totalSupply);
    
    address public tokenImplementation;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) external reinitializer(2) {
        __Ownable_init(initialOwner);
    }

    function setTokenImplementation(address _tokenImpl) external onlyOwner {
        tokenImplementation = _tokenImpl;
    }

    function deployInscription(
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) external onlyOwner returns (address) {
        require(tokenImplementation != address(0), "Token implementation not set");
        
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, totalSupply));
        address clone = tokenImplementation.cloneDeterministic(salt);
        InscriptionToken(clone).initialize(name, symbol, totalSupply);
        emit InscriptionDeployed(clone, name, symbol, totalSupply);
        return clone;
    }

    function predictDeterministicAddress(
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) public view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, totalSupply));
        return tokenImplementation.predictDeterministicAddress(salt, address(this));
    }

    function mintInscription(address tokenAddr, uint256 amount) external {
        InscriptionToken(tokenAddr).mint(msg.sender, amount);
    }
}