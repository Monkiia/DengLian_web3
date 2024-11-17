// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/forge-std/src/console.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./RNT.sol";
import "./interfaces/IStaking.sol";

contract ETHStakingPool is IStaking, ReentrancyGuard, Ownable {
    // 错误定义
    error InvalidZeroAmount();
    error NotEnoughBalance();
    error TransferFailed();
    error EmptyTokenAddress();

    // 事件定义
    event StakeDeposited(address indexed staker, uint256 amount);
    event StakeWithdrawn(address indexed staker, uint256 amount);
    event RewardsClaimed(address indexed staker, uint256 amount);

    struct StakerInfo {
        uint256 stakedAmount;      // 质押数量
        uint256 rewardDebt;        // 已结算奖励
        uint256 pendingRewards;    // 待领取奖励
    }

    RNT public immutable rewardToken;
    uint256 public globalStakeAmount;          // 全局质押总量
    uint256 public lastRewardBlock;            // 上次更新区块
    uint256 public cumulativeRewardPerUnit;    // 单位质押累积奖励

    mapping(address => StakerInfo) public stakerInfos;

    // 精度设置，避免小数计算误差
    uint256 private constant REWARD_PRECISION = 1e24;

    constructor(address _owner, address _rewardToken) Ownable(_owner) {
        if (_rewardToken == address(0)) revert EmptyTokenAddress();
        rewardToken = RNT(_rewardToken);
        lastRewardBlock = block.number;
    }

    // 更新奖励的修饰器
    modifier updateStakingReward() {
        uint256 blocksPassed = block.number - lastRewardBlock;
        
        if (blocksPassed > 0 && globalStakeAmount > 0) {
            uint256 totalRewards = blocksPassed * rewardToken.REWARD_PER_BLOCK();
            uint256 rewardPerUnit = (totalRewards * REWARD_PRECISION * REWARD_PRECISION) / 
                                  (globalStakeAmount * REWARD_PRECISION);
            cumulativeRewardPerUnit += rewardPerUnit;
        }
        lastRewardBlock = block.number;

        address staker = msg.sender;
        StakerInfo storage info = stakerInfos[staker];
        
        if (info.stakedAmount > 0) {
            uint256 newRewards = (info.stakedAmount * cumulativeRewardPerUnit * REWARD_PRECISION) / 
                                (REWARD_PRECISION * REWARD_PRECISION) - info.rewardDebt;
            if (newRewards > 0) {
                info.pendingRewards += newRewards;
            }
            info.rewardDebt = (info.stakedAmount * cumulativeRewardPerUnit * REWARD_PRECISION) / 
                             (REWARD_PRECISION * REWARD_PRECISION);
        }
        _;
    }

    function stake() external payable override nonReentrant updateStakingReward {
        if (msg.value == 0) revert InvalidZeroAmount();

        StakerInfo storage info = stakerInfos[msg.sender];
        info.stakedAmount += msg.value;
        globalStakeAmount += msg.value;

        emit StakeDeposited(msg.sender, msg.value);
    }

    function unstake(uint256 amount) external override nonReentrant updateStakingReward {
        if (amount == 0) revert InvalidZeroAmount();
        
        StakerInfo storage info = stakerInfos[msg.sender];
        if (info.stakedAmount < amount) revert NotEnoughBalance();

        info.stakedAmount -= amount;
        globalStakeAmount -= amount;

        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit StakeWithdrawn(msg.sender, amount);
    }

    function claim() external override nonReentrant updateStakingReward {
        StakerInfo storage info = stakerInfos[msg.sender];
        uint256 rewardAmount = info.pendingRewards;
        
        if (rewardAmount > 0) {
            info.pendingRewards = 0;
            rewardToken.mint(msg.sender, rewardAmount);
            emit RewardsClaimed(msg.sender, rewardAmount);
        }
    }

    function earned(address account) public view override returns (uint256) {
        StakerInfo storage info = stakerInfos[account];
        uint256 currentRewardPerUnit = cumulativeRewardPerUnit;

        if (block.number > lastRewardBlock && globalStakeAmount > 0) {
            uint256 blocksPassed = block.number - lastRewardBlock;
            uint256 totalRewards = blocksPassed * rewardToken.REWARD_PER_BLOCK();
            currentRewardPerUnit += (totalRewards * REWARD_PRECISION * REWARD_PRECISION) / 
                                  (globalStakeAmount * REWARD_PRECISION);
        }

        uint256 newRewards = (info.stakedAmount * currentRewardPerUnit * REWARD_PRECISION) / 
                            (REWARD_PRECISION * REWARD_PRECISION) - info.rewardDebt;
                            
        return info.pendingRewards + newRewards;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return stakerInfos[account].stakedAmount;
    }

    receive() external payable {}
}