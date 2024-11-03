// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

contract esRNT is ERC20 {
    constructor() ERC20("esRNT", "esRNT") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract StakingContract {
    IERC20 public rntToken;
    esRNT public esRntToken;

    struct StakeInfo {
        uint256 amount;            // Amount of RNT staked
        uint256 rewardDebt;        // Accumulated esRNT rewards
        uint256 lastClaimTime;     // Last time of claim
    }

    uint256 public constant REWARD_RATE = 1;  // 1 esRNT per RNT per day
    uint256 public constant UNLOCK_DURATION = 30 days;

    mapping(address => StakeInfo) public stakes;
    mapping(address => uint256) public lockedRewards; // Locked esRNT per address
    mapping(address => uint256) public unlockTime;    // Unlock start time per address

    constructor(IERC20 _rntToken, esRNT _esRntToken) {
        rntToken = _rntToken;
        esRntToken = _esRntToken;
    }

    // Stake RNT tokens to earn esRNT rewards
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        // Transfer RNT from user to the contract
        rntToken.transferFrom(msg.sender, address(this), _amount);

        // Update stake info and rewards
        _updateRewards(msg.sender);

        // Increase user's stake amount
        stakes[msg.sender].amount += _amount;
    }

    // Withdraw staked RNT tokens
    function unstake(uint256 _amount) external {
        require(stakes[msg.sender].amount >= _amount, "Not enough staked");

        // Update rewards before unstaking
        _updateRewards(msg.sender);

        // Decrease user's stake amount
        stakes[msg.sender].amount -= _amount;

        // Transfer RNT tokens back to the user
        rntToken.transfer(msg.sender, _amount);
    }

    // Claim accumulated esRNT rewards
    function claimRewards() external {
        _updateRewards(msg.sender);

        uint256 rewards = stakes[msg.sender].rewardDebt;
        require(rewards > 0, "No rewards available");

        // Reset reward debt
        stakes[msg.sender].rewardDebt = 0;

        // Mint esRNT to user
        esRntToken.mint(msg.sender, rewards);

        // Track lock for 30 days
        lockedRewards[msg.sender] += rewards;
        unlockTime[msg.sender] = block.timestamp + UNLOCK_DURATION;
    }

    // Convert esRNT to RNT (only unlocked esRNT can be converted without penalty)
    function convertEsRNT(uint256 _amount) external {
        require(esRntToken.balanceOf(msg.sender) >= _amount, "Insufficient esRNT balance");

        uint256 unlockableAmount;

        // Calculate unlockable amount based on elapsed time
        if (block.timestamp >= unlockTime[msg.sender]) {
            unlockableAmount = _amount; // All unlocked after 30 days
        } else {
            uint256 timePassed = block.timestamp - (unlockTime[msg.sender] - UNLOCK_DURATION);
            unlockableAmount = (_amount * timePassed) / UNLOCK_DURATION;
        }

        // Burn the esRNT from the user’s balance
        esRntToken.burn(msg.sender, _amount);

        // Calculate penalty: the amount not yet unlocked
        uint256 penaltyAmount = _amount - unlockableAmount;

        // Transfer only the unlocked RNT amount
        if (unlockableAmount > 0) {
            rntToken.transfer(msg.sender, unlockableAmount);
        }

        // If there's a penalty, burn the penalty amount from the user's esRNT
        if (penaltyAmount > 0) {
            console.log("Penalty amount: %s", penaltyAmount);
            console.log("User has %s esRNT", esRntToken.balanceOf(msg.sender));
            esRntToken.burn(msg.sender, penaltyAmount);
        }

        // Adjust the locked rewards for this user
        if (_amount <= lockedRewards[msg.sender]) {
            lockedRewards[msg.sender] -= _amount;
        } else {
            lockedRewards[msg.sender] = 0;
        }
    }


    // Internal function to update user rewards based on staked amount and time
    function _updateRewards(address _user) internal {
        StakeInfo storage userStake = stakes[_user];

        if (userStake.amount > 0) {
            uint256 pendingRewards = ((block.timestamp - userStake.lastClaimTime) * REWARD_RATE * userStake.amount) / 1 days;
            userStake.rewardDebt += pendingRewards;
        }

        userStake.lastClaimTime = block.timestamp;
    }
}
