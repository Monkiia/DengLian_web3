// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console2.sol";
import { ETHStakingPool } from "../src/Staking.sol";
import { RNT } from "../src/RNT.sol";

contract StakingPoolTest is Test {
    ETHStakingPool public stakingPool;
    RNT public rewardToken;

    address public admin;
    address public user1;
    address public user2;

    uint256 public constant USER_INITIAL_BALANCE = 100 ether;
    uint256 public constant REWARD_RATE = 10 ether;

    event StakeDeposited(address indexed staker, uint256 amount);
    event StakeWithdrawn(address indexed staker, uint256 amount);
    event RewardsClaimed(address indexed staker, uint256 amount);

    function setUp() public {
        admin = makeAddr("admin");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vm.startPrank(admin);
        rewardToken = new RNT();
        stakingPool = new ETHStakingPool(admin, address(rewardToken));
        rewardToken.setStakingContract(address(stakingPool));
        vm.stopPrank();

        vm.deal(user1, USER_INITIAL_BALANCE);
        vm.deal(user2, USER_INITIAL_BALANCE);
    }

    function test_RewardsForSingleStaker() public {
        // Initialize test environment
        uint256 initialBlock = 1;
        uint256 depositAmount = 10 ether;
        uint256 blocksPassed = 50;
        
        vm.roll(initialBlock);

        // User1 deposits ETH
        vm.startPrank(user1);
        stakingPool.stake{value: depositAmount}();
        vm.stopPrank();

        // Move forward in time
        vm.roll(initialBlock + blocksPassed);

        // Calculate and verify rewards
        uint256 expectedRewards = blocksPassed * REWARD_RATE;
        uint256 actualRewards = stakingPool.earned(user1);

        console.log("Expected user rewards:", expectedRewards);
        console.log("Actual user rewards:", actualRewards);

        assertEq(actualRewards, expectedRewards, "Reward calculation mismatch");

        // Verify reward claiming
        vm.prank(user1);
        stakingPool.claim();
        assertEq(rewardToken.balanceOf(user1), expectedRewards, "Claimed reward amount mismatch");
    }

    function test_RewardsDistributionMultipleStakers() public {
        uint256 initialBlock = 1;
        uint256 user1Deposit = 10 ether;
        uint256 user2Deposit = 5 ether;
        uint256 blocksPassed = 50;
        
        vm.roll(initialBlock);

        // Users deposit ETH
        vm.prank(user1);
        stakingPool.stake{value: user1Deposit}();
        
        vm.prank(user2);
        stakingPool.stake{value: user2Deposit}();

        // Advance blocks
        vm.roll(initialBlock + blocksPassed);

        // Calculate expected rewards
        uint256 totalRewards = blocksPassed * REWARD_RATE;
        uint256 totalDeposits = user1Deposit + user2Deposit;
        
        uint256 user1ExpectedReward = (totalRewards * user1Deposit * 1e18) / (totalDeposits * 1e18);
        uint256 user2ExpectedReward = (totalRewards * user2Deposit * 1e18) / (totalDeposits * 1e18);

        console.log("Total rewards generated:", totalRewards);
        console.log("User1 expected reward:", user1ExpectedReward);
        console.log("User2 expected reward:", user2ExpectedReward);
        console.log("User1 actual reward:", stakingPool.earned(user1));
        console.log("User2 actual reward:", stakingPool.earned(user2));

        assertEq(stakingPool.earned(user1), user1ExpectedReward, "User1 reward calculation error");
        assertEq(stakingPool.earned(user2), user2ExpectedReward, "User2 reward calculation error");

        vm.prank(user1);
        stakingPool.claim();
        vm.prank(user2);
        stakingPool.claim();

        assertEq(rewardToken.balanceOf(user1), user1ExpectedReward, "User1 final reward error");
        assertEq(rewardToken.balanceOf(user2), user2ExpectedReward, "User2 final reward error");
    }

    function test_StakeUnstakeRewardScenario() public {
        uint256 initialBlock = 1;
        uint256 depositAmount = 10 ether;
        uint256 withdrawAmount = 5 ether;
        uint256 phase1Blocks = 25;
        uint256 phase2Blocks = 25;
        
        vm.roll(initialBlock);

        // Phase 1: Full stake period
        vm.prank(user1);
        stakingPool.stake{value: depositAmount}();

        vm.roll(initialBlock + phase1Blocks);

        uint256 phase1ExpectedReward = phase1Blocks * REWARD_RATE;
        
        vm.prank(user1);
        stakingPool.claim();
        uint256 phase1ActualReward = rewardToken.balanceOf(user1);

        // Phase 2: Partial stake period
        vm.prank(user1);
        stakingPool.unstake(withdrawAmount);

        vm.roll(initialBlock + phase1Blocks + phase2Blocks);

        uint256 phase2ExpectedReward = (phase2Blocks * REWARD_RATE * withdrawAmount * 1e18) / (depositAmount * 1e18);

        vm.prank(user1);
        stakingPool.claim();
        
        uint256 totalActualReward = rewardToken.balanceOf(user1);
        uint256 totalExpectedReward = phase1ExpectedReward + phase2ExpectedReward;

        console.log("=== Reward Distribution ===");
        console.log("Phase 1 rewards:", phase1ActualReward);
        console.log("Phase 2 rewards:", totalActualReward - phase1ActualReward);
        console.log("Total rewards:", totalActualReward);
        console.log("Expected total:", totalExpectedReward);

        assertEq(totalActualReward, totalExpectedReward, "Total reward calculation error");
    }

    function test_RevertZeroStake() public {
        vm.startPrank(user1);
        vm.expectRevert(ETHStakingPool.InvalidZeroAmount.selector);
        stakingPool.stake{value: 0}();
        vm.stopPrank();
    }

    function test_RevertZeroUnstake() public {
        vm.startPrank(user1);
        stakingPool.stake{value: 1 ether}();
        
        vm.expectRevert(ETHStakingPool.InvalidZeroAmount.selector);
        stakingPool.unstake(0);
        vm.stopPrank();
    }

    function test_RevertInsufficientBalance() public {
        vm.startPrank(user1);
        stakingPool.stake{value: 1 ether}();
        
        vm.expectRevert(ETHStakingPool.NotEnoughBalance.selector);
        stakingPool.unstake(2 ether);
        vm.stopPrank();
    }

    function test_RevertUnstakeWithoutStake() public {
        vm.startPrank(user1);
        vm.expectRevert(ETHStakingPool.NotEnoughBalance.selector);
        stakingPool.unstake(1 ether);
        vm.stopPrank();
    }

    function test_MultipleUnstakeWithinBalance() public {
        vm.startPrank(user1);
        
        stakingPool.stake{value: 10 ether}();
        stakingPool.unstake(3 ether);
        stakingPool.unstake(4 ether);
        
        vm.expectRevert(ETHStakingPool.NotEnoughBalance.selector);
        stakingPool.unstake(4 ether);
        
        vm.stopPrank();
    }

    function test_ClaimWithZeroRewards() public {
        vm.startPrank(user1);
        stakingPool.stake{value: 1 ether}();
        
        uint256 balanceBefore = rewardToken.balanceOf(user1);
        stakingPool.claim();
        uint256 balanceAfter = rewardToken.balanceOf(user1);
        
        assertEq(balanceBefore, balanceAfter, "Balance should not change for zero rewards");
        vm.stopPrank();
    }

    function test_ReentrancyProtection() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(stakingPool));
        vm.deal(address(attacker), 5 ether);
        
        vm.expectRevert();
        attacker.attack{value: 1 ether}();
    }

    receive() external payable {}
}

contract ReentrancyAttacker {
    ETHStakingPool public stakingPool;
    bool public attacked;

    constructor(address _stakingPool) {
        stakingPool = ETHStakingPool(payable(_stakingPool));
    }

    function attack() external payable {
        stakingPool.stake{value: msg.value}();
        stakingPool.unstake(msg.value);
    }

    receive() external payable {
        if (!attacked) {
            attacked = true;
            stakingPool.unstake(msg.value);
        }
    }
}