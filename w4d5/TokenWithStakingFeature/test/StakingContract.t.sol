// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakingContract.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestRNT is ERC20 {
    constructor() ERC20("RNT Token", "RNT") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}

contract StakingContractTest is Test {
    StakingContract staking;
    TestRNT rntToken;
    esRNT esRntToken;
    address owner;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        // Deploy RNT and esRNT tokens and staking contract
        rntToken = new TestRNT();
        esRntToken = new esRNT();
        staking = new StakingContract(IERC20(address(rntToken)), esRNT(address(esRntToken)));

        // Transfer RNT to users for testing
        rntToken.transfer(user1, 1_000 * 10 ** rntToken.decimals());
        rntToken.transfer(user2, 1_000 * 10 ** rntToken.decimals());
    }

    function testStakeTokens() public {
        vm.startPrank(user1);

        // Approve and stake tokens
        rntToken.approve(address(staking), 100 * 10 ** rntToken.decimals());
        staking.stake(100 * 10 ** rntToken.decimals());

        // Check that the staked amount is correct
        (uint256 amount, , ) = staking.stakes(user1);
        assertEq(amount, 100 * 10 ** rntToken.decimals(), "Incorrect staked amount");

        vm.stopPrank();
    }

    function testUnstakeTokens() public {
        vm.startPrank(user1);

        // Approve and stake tokens
        rntToken.approve(address(staking), 200 * 10 ** rntToken.decimals());
        staking.stake(200 * 10 ** rntToken.decimals());

        // Unstake partial amount
        staking.unstake(100 * 10 ** rntToken.decimals());
        (uint256 amountAfterPartialUnstake, , ) = staking.stakes(user1);
        assertEq(amountAfterPartialUnstake, 100 * 10 ** rntToken.decimals(), "Incorrect staked amount after partial unstake");

        // Unstake remaining amount
        staking.unstake(100 * 10 ** rntToken.decimals());
        (uint256 amountAfterFullUnstake, , ) = staking.stakes(user1);
        assertEq(amountAfterFullUnstake, 0, "Incorrect staked amount after full unstake");

        vm.stopPrank();
    }

    function testClaimRewards() public {
        vm.startPrank(user1);

        // Approve and stake tokens
        rntToken.approve(address(staking), 100 * 10 ** rntToken.decimals());
        staking.stake(100 * 10 ** rntToken.decimals());

        // Fast forward time by 1 day
        vm.warp(block.timestamp + 1 days);

        // Claim rewards
        staking.claimRewards();
        uint256 expectedRewards = 100 * 1 ether; // 100 RNT staked for 1 day

        assertEq(esRntToken.balanceOf(user1), expectedRewards, "Incorrect rewards claimed");

        vm.stopPrank();
    }

    function testRewardsAccumulateOverTime() public {
        vm.startPrank(user1);

        // Stake tokens
        rntToken.approve(address(staking), 100 * 10 ** rntToken.decimals());
        staking.stake(100 * 10 ** rntToken.decimals());

        // Move forward by 10 days
        vm.warp(block.timestamp + 10 days);

        // Claim rewards
        staking.claimRewards();
        uint256 expectedRewards = 100 * 10 * 10 ** esRntToken.decimals(); // 100 RNT * 10 days = 1000 esRNT

        assertEq(esRntToken.balanceOf(user1), expectedRewards, "Rewards not accumulated correctly over time");

        vm.stopPrank();
    }

function testConvertEsRNTAfterUnlock() public {
    vm.startPrank(user1);

    // Step 1: Approve and stake 100 RNT tokens
    uint256 stakeAmount = 100 * 10 ** rntToken.decimals();
    rntToken.approve(address(staking), stakeAmount);
    staking.stake(stakeAmount);

    // Assert initial stake amount
    (uint256 stakedAmount, , ) = staking.stakes(user1);
    assertEq(stakedAmount, stakeAmount, "Stake amount incorrect after staking");

    // Step 2: Fast-forward by 1 day and claim rewards
    vm.warp(block.timestamp + 1 days);
    staking.claimRewards();

    // Check esRNT balance after claiming rewards
    uint256 esRNTBalance = esRntToken.balanceOf(user1);
    uint256 expectedReward = stakeAmount * 1; // 1 esRNT per RNT staked for 1 day

    assertEq(esRNTBalance, expectedReward, "Incorrect esRNT reward after 1 day");

    // Step 3: Fast-forward by 30 days to fully unlock the esRNT
    vm.warp(block.timestamp + 30 days);

    // Verify that esRNT is still in balance before conversion
    esRNTBalance = esRntToken.balanceOf(user1);
    assertEq(esRNTBalance, expectedReward, "esRNT balance incorrect before conversion");

    uint256 prevRNTBalance = rntToken.balanceOf(user1);

    // Step 4: Convert esRNT to RNT
    staking.convertEsRNT(esRNTBalance);

    // Expected RNT balance should match the esRNT balance because it's fully unlocked
    uint256 expectedRNT = esRNTBalance; // 1:1 conversion

    // Final assertion: Check RNT balance after conversion
    uint256 delta_RNTBalance = rntToken.balanceOf(user1) - prevRNTBalance;
    assertEq(delta_RNTBalance, expectedRNT, "Incorrect RNT received after conversion");

    vm.stopPrank();
}


    function testEarlyEsRNTConversionWithPenalty() public {
        vm.startPrank(user1);

        // Stake and claim rewards
        rntToken.approve(address(staking), 100 * 10 ** rntToken.decimals());
        staking.stake(100 * 10 ** rntToken.decimals());
        vm.warp(block.timestamp + 1 days);
        staking.claimRewards();

        uint256 esRNTBalance = esRntToken.balanceOf(user1);

        // Early conversion with only 9 days elapsed 
        vm.warp(block.timestamp + 10 days);
        staking.claimRewards();
        staking.convertEsRNT(esRNTBalance);

        uint256 expectedUnlocked = esRNTBalance * 9; 
        assertEq(rntToken.balanceOf(user1), expectedUnlocked, "Incorrect RNT received after early conversion with penalty");

        vm.stopPrank();
    }

    function testPartialStakeUnstakeRewardAccrual() public {
        vm.startPrank(user1);

        // Stake tokens
        rntToken.approve(address(staking), 100 * 10 ** rntToken.decimals());
        staking.stake(100 * 10 ** rntToken.decimals());

        // Move forward by 5 days and unstake half
        vm.warp(block.timestamp + 5 days);
        staking.unstake(50 * 10 ** rntToken.decimals());

        // Move forward by another 5 days
        vm.warp(block.timestamp + 5 days);

        // Claim rewards
        staking.claimRewards();
        uint256 expectedRewards = 500 + 250; // (100 * 5 days + 50 * 5 days) * 1 esRNT per RNT per day
        assertEq(esRntToken.balanceOf(user1), expectedRewards * 10 ** esRntToken.decimals(), "Incorrect rewards after partial unstake");

        vm.stopPrank();
    }

    function testMultipleUsersStaking() public {
        vm.startPrank(user1);
        rntToken.approve(address(staking), 100 * 10 ** rntToken.decimals());
        staking.stake(100 * 10 ** rntToken.decimals());
        vm.stopPrank();

        vm.startPrank(user2);
        rntToken.approve(address(staking), 200 * 10 ** rntToken.decimals());
        staking.stake(200 * 10 ** rntToken.decimals());
        vm.stopPrank();

        // Move forward by 5 days and each user claims rewards
        vm.warp(block.timestamp + 5 days);

        vm.startPrank(user1);
        staking.claimRewards();
        assertEq(esRntToken.balanceOf(user1), 500 * 10 ** esRntToken.decimals(), "User1 incorrect reward calculation");
        vm.stopPrank();

        vm.startPrank(user2);
        staking.claimRewards();
        assertEq(esRntToken.balanceOf(user2), 1000 * 10 ** esRntToken.decimals(), "User2 incorrect reward calculation");
        vm.stopPrank();
    }
}
