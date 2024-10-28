// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InscriptionToken is ERC20, Ownable {
    uint public totalSupplyLimit; // Total limit of tokens allowed to be minted
    uint public perMint;          // Amount of tokens minted per mint call
    uint public mintedAmount;      // Tracks the total amount minted so far

    /**
     * @dev Initializes the ERC20 token with supply limits and assigns ownership.
     * @param name The token name
     * @param symbol The token symbol
     * @param totalSupply The maximum supply for the token
     * @param _perMint The minting amount per call
     * @param owner The address set as the owner of the token (factory creator)
     */
    constructor(
        string memory name,
        string memory symbol,
        uint totalSupply,
        uint _perMint,
        address owner
    ) ERC20(name, symbol) Ownable(owner) {
        totalSupplyLimit = totalSupply;
        perMint = _perMint;
        mintedAmount = 0;
    }

    /**
     * @dev Mints tokens to the specified address, respecting the perMint and total supply limits.
     * @param to The address to receive the minted tokens
     */
    function mint(address to) public onlyOwner {
        require(mintedAmount + perMint <= totalSupplyLimit, "Exceeds total supply limit");

        _mint(to, perMint); // Mint tokens to the specified address
        mintedAmount += perMint; // Update the total minted amount
    }
}
