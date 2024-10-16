// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract BankTest is Test {
    Bank public bank;
    address alice;
    address bob;

    function setUp() public {
        bank = new Bank();
        // Set mock addresses for Alice and Bob
        alice = address(0x1234);
        bob = address(0x5678);
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    // Test multiple deposits
    function test_Deposit_succeed() public {
        bank.depositETH{value: 100}();
        assertEq(bank.balanceOf(address(this)), 100);
        assertEq(address(bank).balance, 100);
        // Second deposit, to see if the balance is added
        bank.depositETH{value: 100}();
        assertEq(bank.balanceOf(address(this)), 200);
        assertEq(address(bank).balance, 200);
    }

    function testDepositETHFromMultipleAddresses() public {
        uint aliceDeposit = 1 ether;
        uint bobDeposit = 2 ether;

        // Prank Alice and send ETH
        vm.prank(alice);
        console.log("Alice is depositing:", aliceDeposit); // Print deposit amount
        bank.depositETH{value: aliceDeposit}();
        console.log("Alice's balance after deposit:", bank.balanceOf(alice)); // Print Alice's balance
        assertEq(bank.balanceOf(alice), aliceDeposit, "Alice's balance should be updated");

        // Prank Bob and send ETH
        vm.prank(bob);
        console.log("Bob is depositing:", bobDeposit); // Print deposit amount
        bank.depositETH{value: bobDeposit}();
        console.log("Bob's balance after deposit:", bank.balanceOf(bob)); // Print Bob's balance
        assertEq(bank.balanceOf(bob), bobDeposit, "Bob's balance should be updated");

        // Check that Alice's balance is still correct after Bob's deposit
        console.log("Alice's balance should not have changed after Bob's deposit:", bank.balanceOf(alice));
        assertEq(bank.balanceOf(alice), aliceDeposit, "Alice's balance should not change after Bob's deposit");
    }


    // Additional test for zero deposit in a sequence
    function testDepositFailsOnZeroValue() public {
        // Initial deposit works
        bank.depositETH{value: 1 ether}();
        assertEq(bank.balanceOf(address(this)), 1 ether);

        // Zero deposit should fail
        vm.expectRevert(bytes("Deposit amount must be greater than 0"));
        bank.depositETH{value: 0}();
    }

    // Fuzz test for deposit function
    function testFuzz_Deposit(uint256 depositAmount) public {
        // Skip this fuzz test if depositAmount is 0, since it would revert
        vm.assume(depositAmount > 0);

        // Mock a user address
        address user = address(0xABCDEF);

        // Prank the user and call the depositETH function with the fuzzed amount
        vm.prank(user);
        vm.deal(user, depositAmount);
        bank.depositETH{value: depositAmount}();

        // Assert that the balance of the user is updated correctly
        assertEq(bank.balanceOf(user), depositAmount, "Balance should be updated correctly");
    }
}
