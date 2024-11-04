// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EsRNT.sol";

contract Staking {
    IERC20 public rntToken;
    EsRNT public esRntToken;
    uint256 public constant REWARD_RATE = 1; // 每天每个 RNT 可获得 1 个 esRNT
    uint256 public constant UNLOCK_DURATION = 30 days;

    struct StakeInfo {
        uint256 amount;            // Amount of RNT staked
        uint256 rewardDebt;        // Accumulated esRNT rewards
        uint256 lastClaimTime;     // Last time of claim
    }

    mapping(address => StakeInfo) public stakes;

    constructor(IERC20 _rntToken) {
        rntToken = _rntToken;
    }

    function initialize(EsRNT _esRntToken) external {
        require(address(esRntToken) == address(0), "Already initialized");
        esRntToken = _esRntToken;
    }

    // Stake RNT tokens
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        // Transfer RNT from the user
        rntToken.transferFrom(msg.sender, address(this), _amount);

        // Update accrued rewards before adding more to the stake
        _updateRewards(msg.sender);

        // Increase staked amount
        stakes[msg.sender].amount += _amount;
    }

    // Unstake RNT tokens
    function unstake(uint256 _amount) external {
        require(stakes[msg.sender].amount >= _amount, "Insufficient staked amount");

        // Update rewards before unstaking
        _updateRewards(msg.sender);

        // Reduce staked amount
        stakes[msg.sender].amount -= _amount;

        // Transfer RNT back to the user
        rntToken.transfer(msg.sender, _amount);
    }

    // Claim accumulated esRNT rewards
    function claimRewards() external returns (uint256) {
        _updateRewards(msg.sender);

        uint256 rewards = stakes[msg.sender].rewardDebt;
        require(rewards > 0, "No rewards available");

        // Reset reward debt after claiming
        stakes[msg.sender].rewardDebt = 0;

        uint256 unlockTime = block.timestamp + UNLOCK_DURATION;

        // Mint esRNT tokens to user with specific unlock time
        esRntToken.mint(msg.sender, rewards, unlockTime);

        return unlockTime;
    }

    // Internal function to update user rewards based on staked amount and time
    function _updateRewards(address _user) internal {
        StakeInfo storage userStake = stakes[_user];

        if (userStake.amount > 0) {
            uint256 timeElapsed = block.timestamp - userStake.lastClaimTime;
            uint256 pendingRewards = (timeElapsed * REWARD_RATE * userStake.amount) / 1 days;
            userStake.rewardDebt += pendingRewards;
        }

        // Update last claim time
        userStake.lastClaimTime = block.timestamp;
    }

    // Convert esRNT to RNT based on unlock time
    function convertEsRNTToRNT(uint256 _unlockTime) external {
        esRntToken.burn(msg.sender, _unlockTime);
    }
}
