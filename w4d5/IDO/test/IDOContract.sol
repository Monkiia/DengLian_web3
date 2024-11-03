// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/IDOContract.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor() ERC20("Test Token", "TST") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}

contract TestIDOContract is Test {
    IDOContract ido;
    TestToken token;
    address owner;
    address user1;
    address user2;
    address user3;

    function setUp() public {
        owner = address(0x1234);
        user1 = address(0x1);
        user2 = address(0x2);
        user3 = address(0x3);

        // Deploy a test token and the IDO contract
        token = new TestToken();
        vm.prank(owner);
        ido = new IDOContract();
        vm.stopPrank();
    }

    function testFundraisingSuccess() public {
        // Start the presale with goal of 10 ETH and cap of 15 ETH
        uint256 presalePrice = 1 ether; // 1 ETH per token
        uint256 goal = 10 ether;
        uint256 maxCap = 15 ether;
        uint256 duration = 1 days;
        
        vm.prank(owner);
        ido.startPresale(IERC20(address(token)), presalePrice, goal, maxCap, duration);

        // Transfer tokens to the contract for distribution
        token.transfer(address(ido), 10000 * 10 ** 18);

        // Simulate contributions from users
        vm.deal(user1, 5.5 ether);
        vm.deal(user2, 3.5 ether);
        vm.deal(user3, 2.5 ether);
        

        vm.prank(user1);
        ido.participate{value: 5 ether}();

        vm.prank(user2);
        ido.participate{value: 3 ether}();

        vm.prank(user3);
        ido.participate{value: 2 ether}();

        // Check if fundraising succeeded
        assertEq(ido.totalEthRaised(), 10 ether);

        // Move time to end the presale
        vm.warp(block.timestamp + duration + 1);

        // Users claim tokens
        vm.prank(user1);
        ido.claimTokens();

        vm.prank(user2);
        ido.claimTokens();

        vm.prank(user3);
        ido.claimTokens();

        // Check that tokens are transferred
        assertEq(token.balanceOf(user1), 5 * 10 ** 18);
        assertEq(token.balanceOf(user2), 3 * 10 ** 18);
        assertEq(token.balanceOf(user3), 2 * 10 ** 18);

        // Owner withdraws the raised ETH
        uint256 initialOwnerBalance = owner.balance;
        vm.prank(owner);
        ido.withdraw();
        assertEq(owner.balance, initialOwnerBalance + 10 ether);
    }

    function testFundraisingFailWithRefunds() public {
        // Start the presale with goal of 10 ETH but contributions only total 5 ETH
        uint256 presalePrice = 1 ether;
        uint256 goal = 10 ether;
        uint256 maxCap = 15 ether;
        uint256 duration = 1 days;

        vm.prank(owner);
        ido.startPresale(IERC20(address(token)), presalePrice, goal, maxCap, duration);

        // Transfer tokens to the contract for distribution
        token.transfer(address(ido), 10000 * 10 ** 18);

        // Simulate contributions from users
        vm.deal(user1, 3 ether);
        vm.deal(user2, 2 ether);

        vm.prank(user1);
        ido.participate{value: 3 ether}();

        vm.prank(user2);
        ido.participate{value: 2 ether}();

        // Check if fundraising failed
        assertEq(ido.totalEthRaised(), 5 ether);

        // Move time to end the presale
        vm.warp(block.timestamp + duration + 1);

        // Users claim refunds
        vm.prank(user1);
        ido.claimRefund();
        assertEq(user1.balance, 3 ether);

        vm.prank(user2);
        ido.claimRefund();
        assertEq(user2.balance, 2 ether);
    }

    function testProjectCancellation() public {
        // Start the presale
        uint256 presalePrice = 1 ether;
        uint256 goal = 10 ether;
        uint256 maxCap = 15 ether;
        uint256 duration = 1 days;

        vm.prank(owner);
        ido.startPresale(IERC20(address(token)), presalePrice, goal, maxCap, duration);

        // Simulate contributions
        vm.deal(user1, 5 ether);
        vm.prank(user1);
        ido.participate{value: 5 ether}();

        // Cancel the presale midway
        vm.prank(owner);
        ido.endPresale();

        // Ensure users can still claim refunds
        vm.prank(user1);
        ido.claimRefund();
        assertEq(user1.balance, 5 ether);
    }

    function testEdgeCaseMaxCapExceeded() public {
        uint256 presalePrice = 1 ether;
        uint256 goal = 10 ether;
        uint256 maxCap = 10 ether; // Same as goal for this edge case
        uint256 duration = 1 days;

        vm.prank(owner);
        ido.startPresale(IERC20(address(token)), presalePrice, goal, maxCap, duration);

        // Transfer tokens to the contract for distribution
        token.transfer(address(ido), 10000 * 10 ** 18);

        vm.deal(user1, 10 ether);
        vm.prank(user1);
        ido.participate{value: 10 ether}();

        // Verify fundraising cap reached
        assertEq(ido.totalEthRaised(), maxCap);

        // Additional participation should be blocked
        vm.deal(user2, 1 ether);
        vm.prank(user2);
        vm.expectRevert("Exceeds maxCap");
        ido.participate{value: 1 ether}();
    }

    function testTokenClaimingWithoutContribution() public {
        uint256 presalePrice = 1 ether;
        uint256 goal = 10 ether;
        uint256 maxCap = 15 ether;
        uint256 duration = 1 days;

        vm.prank(owner);
        ido.startPresale(IERC20(address(token)), presalePrice, goal, maxCap, duration);

        vm.deal(user1, 10 ether);
        vm.prank(user1);
        ido.participate{value: 10 ether}();

        // Move time to end the presale
        vm.warp(block.timestamp + duration + 1);

        // Non-contributor tries to claim tokens
        vm.deal(user2, 1 ether);
        vm.prank(user2);
        vm.expectRevert("No contribution");
        ido.claimTokens();
    }
}
