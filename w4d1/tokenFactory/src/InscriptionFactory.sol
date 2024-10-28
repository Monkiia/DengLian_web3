// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {InscriptionToken} from "./InscriptionToken.sol";

contract InscriptionFactory {
    struct TokenInfo {
        address tokenAddress; // Address of the deployed token
        uint totalSupply;     // Total supply of the token
        uint perMint;         // Amount to mint per call
    }

    // Mapping to store deployed tokens' information
    mapping(address => TokenInfo) public tokens;
    address[] public allTokens; // Array to keep track of all tokens created

    // Event emitted when a new token is deployed
    event InscriptionDeployed(address tokenAddress, string symbol, uint totalSupply, uint perMint);

    /**
     * @dev Deploys a new ERC20 token and stores its information.
     * @param symbol The token symbol
     * @param totalSupply The total supply limit of the token
     * @param perMint The amount to mint per `mintInscription` call
     * @return The address of the newly deployed token
     */
    function deployInscription(string memory symbol, uint totalSupply, uint perMint) public returns (address) {
        // Deploy a new InscriptionToken instance
        InscriptionToken newToken = new InscriptionToken(symbol, symbol, totalSupply, perMint, address(this));
        address tokenAddress = address(newToken);

        // Store the new token's details in the mapping
        tokens[tokenAddress] = TokenInfo(tokenAddress, totalSupply, perMint);
        allTokens.push(tokenAddress); // Add to array of all tokens

        emit InscriptionDeployed(tokenAddress, symbol, totalSupply, perMint);

        return tokenAddress;
    }

    /**
     * @dev Mints the specified amount of tokens as defined in `perMint`.
     * @param tokenAddr The address of the token contract to mint from
     */
    function mintInscription(address tokenAddr) public {
        require(tokens[tokenAddr].tokenAddress != address(0), "Token not found");

        // Mint tokens by calling the mint function in the token contract
        InscriptionToken token = InscriptionToken(tokenAddr);
        token.mint(msg.sender);
    }
}
