// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RNT is ERC20, Ownable {
    // custom error
    error ExceedsMaxSupply(uint256 maxSupply, uint256 currentSupply, uint256 mintAmount);
    error OnlyStakingContract();

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;
    uint256 public constant REWARD_PER_BLOCK = 10 * 10 ** 18;

    address public stakingContract;

    constructor() ERC20("RNT", "RNT") Ownable(msg.sender) { }

    function setStakingContract(address _stakingContract) external onlyOwner {
        stakingContract = _stakingContract;
    }

    function mint(address to, uint256 amount) external {
        // only staking contract can mint
        if (msg.sender != stakingContract) revert OnlyStakingContract();

        if (totalSupply() + amount > MAX_SUPPLY) {
            revert ExceedsMaxSupply(MAX_SUPPLY, totalSupply(), amount);
        }
        _mint(to, amount);
    }

    function remainingMintableSupply() public view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }
}