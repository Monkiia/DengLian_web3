// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/RNT.sol";
import "../src/EsRNT.sol";
import "../src/Staking.sol";

contract StakingTest is Test {
    RNT public rntToken;
    EsRNT public esRntToken;
    Staking public staking;

    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    uint256 public constant INITIAL_RNT_BALANCE = 1000 * 1e18;
    uint256 public constant STAKE_AMOUNT = 100 * 1e18;
    uint256 public constant REWARD_RATE = 1 * 1e18; // 1 esRNT per RNT per day

    function setUp() public {
        // Deploy RNT token and mint to user accounts
        rntToken = new RNT();
        esRntToken = new EsRNT(IERC20(rntToken));
        staking = new Staking(IERC20(rntToken));

        esRntToken.initialize(address(staking));
        staking.initialize(esRntToken);

        rntToken.mint(user1, INITIAL_RNT_BALANCE);
        rntToken.mint(user2, INITIAL_RNT_BALANCE);
        rntToken.mint(user3, INITIAL_RNT_BALANCE);
        rntToken.mint(address(esRntToken), INITIAL_RNT_BALANCE * 100);

        // Approve staking contract to spend user tokens
        vm.prank(user1);
        rntToken.approve(address(staking), INITIAL_RNT_BALANCE);

        vm.prank(user2);
        rntToken.approve(address(staking), INITIAL_RNT_BALANCE);

        vm.prank(user3);
        rntToken.approve(address(staking), INITIAL_RNT_BALANCE);
    }

    function testStake() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        vm.stopPrank();

        assertEq(rntToken.balanceOf(user1), INITIAL_RNT_BALANCE - STAKE_AMOUNT);
        assertEq(rntToken.balanceOf(address(staking)), STAKE_AMOUNT);
    }

    function testUnstake() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        staking.unstake(STAKE_AMOUNT);
        vm.stopPrank();

        assertEq(rntToken.balanceOf(user1), INITIAL_RNT_BALANCE);
        assertEq(rntToken.balanceOf(address(staking)), 0);
    }

    function testUnstakePartial() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        staking.unstake(STAKE_AMOUNT / 2);
        vm.stopPrank();

        assertEq(rntToken.balanceOf(user1), INITIAL_RNT_BALANCE - (STAKE_AMOUNT / 2));
    }

    function testClaimRewardsAfterOneDay() public {
        vm.startPrank(user1);

        // Stake 100 RNT
        staking.stake(STAKE_AMOUNT);

        // Advance time by exactly 1 day from the staking time
        vm.warp(block.timestamp + 1 days);

        // Claim rewards after exactly 1 day
        uint256 unlockTime = staking.claimRewards();
        vm.stopPrank();

        // Expected rewards for 1 day of staking 100 RNT
        uint256 expectedRewards = STAKE_AMOUNT;

        // Allow a small tolerance in the assertion
        assertEq(esRntToken.balanceOf(user1), expectedRewards, "Rewards after 1 day of staking 100 RNT");
    }

    function testClaimRewardsMultipleDays() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + 2 days);
        staking.claimRewards();
        vm.stopPrank();

        uint256 expectedRewards = STAKE_AMOUNT * 2; // 2 days of rewards
        assertEq(esRntToken.balanceOf(user1), expectedRewards, "Rewards after 2 days of staking 100 RNT");
    }

    function testMultipleStakesAndThenClaim() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + 1 days);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + 2 days);
        staking.claimRewards();

        uint256 expectedRewards = STAKE_AMOUNT * 5; // 5 = 1 + 2 + 2 days of rewards
        assertEq(esRntToken.balanceOf(user1), expectedRewards, "Rewards after multiple states");
        vm.stopPrank();
    }

    function testEarlyEsRNTConversionWithPenalty() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + 1 days); // 1 day of staking
        uint256 timestamp = staking.claimRewards();
        
        uint256 esRNTBalance = esRntToken.balanceOf(user1);
        
        // Simulate early conversion 20 days before maturrity
        vm.warp(timestamp - 20 days);
        uint256 prev_RNT_Balance = rntToken.balanceOf(user1);
        staking.convertEsRNTToRNT(timestamp);
        vm.stopPrank();

        uint256 expectedRNT = (esRNTBalance * 10 days) / 30 days;
        assertEq(rntToken.balanceOf(user1), prev_RNT_Balance + expectedRNT, "RNT balance after early conversion with penalty");
        assertEq(esRntToken.balanceOf(user1), 0);
    }


    function testLateEsRNTConversionWithPenalty() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + 1 days); // 1 day of staking
        uint256 timestamp = staking.claimRewards();
        
        uint256 esRNTBalance = esRntToken.balanceOf(user1);
        
        // Simulate early conversion 20 days before maturrity
        vm.warp(timestamp + 30 days);
        uint256 prev_RNT_Balance = rntToken.balanceOf(user1);
        staking.convertEsRNTToRNT(timestamp);
        vm.stopPrank();

        uint256 expectedRNT = (esRNTBalance * 30 days) / 30 days;
        assertEq(rntToken.balanceOf(user1), prev_RNT_Balance + expectedRNT, "RNT balance after late conversion with penalty");
        assertEq(esRntToken.balanceOf(user1), 0);
    }


    function testMultipleUsersStakeAndClaim() public {
        // User1 stakes and claims rewards
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        
        // Move forward 1 day for user1's rewards
        uint256 user1StakeTime = block.timestamp;
        vm.warp(user1StakeTime + 1 days);
        uint256 user1_unlock_time = staking.claimRewards();
        vm.stopPrank();

        // Reset the block time for User2
        vm.warp(user1StakeTime); // Reset to user1's initial staking time

        // User2 stakes and claims rewards
        vm.startPrank(user2);
        staking.stake(STAKE_AMOUNT);
        
        // Move forward 1 day for user2's rewards independently
        uint256 user2StakeTime = block.timestamp;
        vm.warp(user2StakeTime + 1 days);
        uint256 user2_unlock_time = staking.claimRewards();
        vm.stopPrank();

        // Check individual rewards
        uint256 user1Rewards = STAKE_AMOUNT; // 1 day of rewards for user1
        uint256 user2Rewards = STAKE_AMOUNT; // 1 day of rewards for user2
        // Allow a small tolerance in the assertions
        assertEq(esRntToken.balanceOf(user1), user1Rewards,"User1 rewards after staking");
        assertEq(esRntToken.balanceOf(user2), user2Rewards, "User2 rewards after staking");
    }


    function testUnstakeAfterClaimingRewards() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + 1 days);
        staking.claimRewards();
        staking.unstake(STAKE_AMOUNT);
        vm.stopPrank();

        uint256 expectedRewards = STAKE_AMOUNT; // 1 day of rewards for staking
        assertEq(esRntToken.balanceOf(user1), expectedRewards, "Rewards after unstaking and claiming");
    }

    function testUnstakeAndPartialClaimRewards() public {
        vm.startPrank(user1);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + 1 days);
        staking.claimRewards();
        staking.unstake(STAKE_AMOUNT / 2);
        vm.warp(block.timestamp + 1 days); // Move forward another day
        staking.claimRewards();
        vm.stopPrank();

        uint256 totalExpectedRewards = STAKE_AMOUNT + (STAKE_AMOUNT / 2);
        assertEq(esRntToken.balanceOf(user1), totalExpectedRewards, "Total rewards after partial unstake and multiple claims");
    }

function testConvertEsRNTwithMultipleMaturityDates() public {
    vm.startPrank(user1);

    // Step 1: Stake 100 RNT (STAKE_AMOUNT)
    staking.stake(STAKE_AMOUNT);

    // Step 2: Fast-forward 1 day, claim rewards (first batch of 100 esRNT at timestamp1)
    vm.warp(block.timestamp + 1 days);
    uint256 timestamp1 = staking.claimRewards();
    uint256 day1_esRntBalance = esRntToken.balanceOf(user1);

    // Check that first claim provides expected amount (100 esRNT)
    assertEq(day1_esRntBalance, STAKE_AMOUNT, "First batch of esRNT should be 100");

    // Step 3: Fast-forward another day (total 2 days), claim rewards again (second batch of 100 esRNT at timestamp2)
    vm.warp(block.timestamp + 1 days);
    uint256 timestamp2 = staking.claimRewards();

    // Verify total esRNT balance after second claim (should be 200 esRNT)
    uint256 totalEsRntBalance = esRntToken.balanceOf(user1);
    assertEq(totalEsRntBalance, STAKE_AMOUNT * 2, "Total esRNT balance should be 200 after second claim");

    // Step 4: Fast-forward to day 30 (28 more days), convert only timestamp1 rewards
    vm.warp(block.timestamp + 30 days);
    uint256 prevRNTBalance = rntToken.balanceOf(user1);
    staking.convertEsRNTToRNT(timestamp1);

    // Verify that only the first batch has converted, adding 100 RNT to user's balance
    assertEq(rntToken.balanceOf(user1), prevRNTBalance + STAKE_AMOUNT, "RNT balance after converting esRNTs from timestamp1");

    // Verify that the second batch of esRNT (timestamp2) is still locked
    uint256 remainingEsRntBalance = esRntToken.balanceOf(user1);
    assertEq(remainingEsRntBalance, STAKE_AMOUNT, "Remaining esRNT balance should be from timestamp2 only and still locked");

    vm.stopPrank();
}


}
