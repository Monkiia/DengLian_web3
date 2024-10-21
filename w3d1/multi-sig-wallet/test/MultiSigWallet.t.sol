// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;
    address[] owners;
    address owner1 = address(0x123);
    address owner2 = address(0x456);
    address owner3 = address(0x789);

    function setUp() public {
        // Initialize wallet with 3 owners and a threshold of 2 approvals
        owners.push(owner1);
        owners.push(owner2);
        owners.push(owner3);
        wallet = new MultiSigWallet(owners);
        // Fund the wallet contract with 1 Ether
        (bool sent, ) = address(wallet).call{value: 1 ether}("");
        require(sent, "Failed to send Ether to the wallet");
    }

    function testProposalAndApproval() public {
        // Owner1 proposes a transaction
        vm.startPrank(owner1);
        wallet.propose(address(0x5), 100);
        vm.stopPrank();

        // Owner2 approves the proposal
        vm.startPrank(owner2);
        wallet.approve(0);
        vm.stopPrank();

        // Check that the proposal has 2 approvals and is executed
        (address destination, uint value, bool executed, uint approvalCount) = wallet.proposals(0);
        assertEq(destination, address(0x5));
        assertEq(value, 100);
        assertEq(executed, true);  // Transaction should be executed after second approval
        assertEq(approvalCount, 2);
    }

    function testExecuteWithoutEnoughApprovals() public {
        // Owner1 proposes a transaction
        vm.startPrank(owner1);
        wallet.propose(address(this), 100);
        vm.stopPrank();

        // Check proposal not executed yet
        (address destination, uint value, bool executed, uint approvalCount) = wallet.proposals(0);
        assertEq(executed, false);  // Transaction should not be executed
    }

    function testCannotApproveTwice() public {
        // Owner1 proposes a transaction
        vm.startPrank(owner1);
        wallet.propose(address(this), 100);

        // Owner2 tries to approve again (should revert)
        vm.expectRevert("Already approved");
        wallet.approve(0);
        vm.stopPrank();
    }

    function testExecute() public {
        vm.deal(address(wallet), 1000); // Fund the wallet
        vm.prank(owner1);
        wallet.propose(address(0x5), 500);

        vm.prank(owner2);
        wallet.approve(0);

        // Anyone can execute as long as has enough approvals
        vm.prank(address(0x888));
        vm.expectRevert("Proposal already executed");
        // but becuase it already crossed threshold and appovals lead to auto execute, thus we have the already execution error
        wallet.execute(0);
        vm.stopPrank();

    }
}
