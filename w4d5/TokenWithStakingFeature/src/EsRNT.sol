// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EsRNT is ERC20 {
    IERC20 public rntToken;
    uint256 public constant LOCK_DURATION = 30 days;

    // Authorized staking contract address
    address public stakingContract;

    // Mapping for each user's mint records based on unlock time
    mapping(address => mapping(uint256 => uint256)) public mintRecords;

    constructor(IERC20 _rntToken) ERC20("esRNT", "eRNT") {
        rntToken = _rntToken;
    }

    function initialize(address _stakingContract) external {
        require(stakingContract == address(0), "Already initialized");
        stakingContract = _stakingContract;
    }

    modifier onlyStakingContract() {
        require(msg.sender == stakingContract, "Only staking contract can call this function");
        _;
    }

    // Mint esRNT with specific unlock time
    function mint(address _user, uint256 _amount, uint256 _unlockTime) external onlyStakingContract {
        require(_amount > 0, "Amount must be greater than zero");
        require(_unlockTime > block.timestamp, "_unlockTime must be in the future");

        mintRecords[_user][_unlockTime] = _amount;
        _mint(_user, _amount);
    }

    // Burn esRNT based on unlock time and transfer RNT accordingly
    function burn(address _user, uint256 _unlockTime) external onlyStakingContract {
        uint256 amount = mintRecords[_user][_unlockTime];
        require(balanceOf(_user) >= amount, "Insufficient esRNT balance");

        uint256 redeemableAmount;
        if (block.timestamp >= _unlockTime) {
            redeemableAmount = amount; // Fully unlocked
        } else {
            // Calculate partially unlocked amount
            uint256 timeLeft = _unlockTime - block.timestamp;
            redeemableAmount = (amount * (LOCK_DURATION - timeLeft)) / LOCK_DURATION;
        }

        mintRecords[_user][_unlockTime] = 0; // Clear the record
        _burn(_user, amount);
        rntToken.transfer(_user, redeemableAmount);
    }
}
