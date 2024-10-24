// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/tokenBank.sol";
import "../src/Token.sol";

contract TokenBankTest is Test {
    MyPermitToken public myToken;
    tokenBank public bank;

    address public user1 = address(0x123);
    address public user2 = address(0x456);

    // Define the private key for the user (whitelist signer)
    uint256 userPrivateKey = 0xA22CD;

    function setUp() public {
        // Deploy the token
        myToken = new MyPermitToken();

        // Deploy the bank and pass the address of the token
        bank = new tokenBank(address(myToken));

        // Give user1 and user2 some tokens
        myToken.transfer(user1, 1000 * 10 ** myToken.decimals());
        myToken.transfer(user2, 1000 * 10 ** myToken.decimals());

        // Allow Foundry to manage the test addresses (user1, user2)
        vm.startPrank(user1);
    }

    function testDeposit() public {
        uint256 depositAmount = 100 * 10 ** myToken.decimals();

        // Approve the bank to spend tokens
        myToken.approve(address(bank), depositAmount);

        // Deposit tokens
        bank.deposit(depositAmount);

        // Check that the balance in the bank is updated
        uint256 balance = bank.getBalance(user1);
        assertEq(balance, depositAmount);

        // Check that user1's token balance decreased
        uint256 userBalance = myToken.balanceOf(user1);
        assertEq(userBalance, 900 * 10 ** myToken.decimals());
    }

    function testWithdraw() public {
        uint256 depositAmount = 100 * 10 ** myToken.decimals();

        // Approve and deposit tokens
        myToken.approve(address(bank), depositAmount);
        bank.deposit(depositAmount);

        // Withdraw the tokens
        bank.withdrawl(depositAmount);

        // Check that the bank balance is 0 after withdrawal
        uint256 balance = bank.getBalance(user1);
        assertEq(balance, 0);

        // Check that user1's token balance is back to the original amount
        uint256 userBalance = myToken.balanceOf(user1);
        assertEq(userBalance, 1000 * 10 ** myToken.decimals());
    }

    function testPermitDeposit() public {
        uint256 depositAmount = 100 * 10 ** myToken.decimals();
        address user = vm.addr(userPrivateKey);
        myToken.transfer(user, 1000 * 10 ** myToken.decimals());

        // Start pranking user1 (this simulates transactions from user1)
        vm.startPrank(user);

        // Simulate user signing a permit for the bank to spend tokens
        uint256 nonce = myToken.nonces(user);
        uint256 deadline = block.timestamp + 1 days;

        // Generate the permit signature
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, keccak256(abi.encodePacked(
            "\x19\x01",
            myToken.DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                user,
                address(bank),
                depositAmount,
                nonce,
                deadline
            ))
        )));

        // Call permitDeposit (using the signature)
        bank.permitDeposit(depositAmount, deadline, v, r, s);

        // Stop the prank
        vm.stopPrank();

        // Check that the balance in the bank is updated
        uint256 balance = bank.getBalance(user);
        assertEq(balance, depositAmount);

        // Check that user's token balance decreased
        uint256 userBalance = myToken.balanceOf(user);
        assertEq(userBalance, 900 * 10 ** myToken.decimals());
    }


    function generatePermitHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) internal pure returns (bytes32) {
        // This mimics the hashing of a permit, ensure you pass the correct values here
        return keccak256(abi.encodePacked(owner, spender, value, nonce, deadline));
    }


    // Test invalid signature should fail
    function testPermitDeposit_invalidSignature() public {
        uint256 depositAmount = 100 * 10 ** myToken.decimals();
        address user = vm.addr(userPrivateKey);
        myToken.transfer(user, 1000 * 10 ** myToken.decimals());

        // Start pranking user1 (this simulates transactions from user1)
        vm.startPrank(user);

        // Simulate user signing a permit for the bank to spend tokens
        uint256 nonce = myToken.nonces(user);
        uint256 deadline = block.timestamp + 1 days;

        // Generate a valid permit signature
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, keccak256(abi.encodePacked(
            "\x19\x01",
            myToken.DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                user,
                address(bank),
                depositAmount,
                nonce,
                deadline
            ))
        )));

        // Tamper with the signature (e.g., change v to an invalid value)
        v += 1;

        // Expect the transaction to revert with an invalid signature error
        vm.expectRevert();
        bank.permitDeposit(depositAmount, deadline, v, r, s);

        vm.stopPrank();
    }

    // Test insufficient balance should fail
    function testPermitDeposit_insufficientBalance() public {
        uint256 depositAmount = 2000 * 10 ** myToken.decimals();  // More than the user's balance
        address user = vm.addr(userPrivateKey);
        myToken.transfer(user, 1000 * 10 ** myToken.decimals());  // Transfer only 1000 tokens to user

        // Start pranking user1 (this simulates transactions from user1)
        vm.startPrank(user);

        // Simulate user signing a permit for the bank to spend tokens
        uint256 nonce = myToken.nonces(user);
        uint256 deadline = block.timestamp + 1 days;

        // Generate the permit signature
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, keccak256(abi.encodePacked(
            "\x19\x01",
            myToken.DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                user,
                address(bank),
                depositAmount,
                nonce,
                deadline
            ))
        )));

        // Expect the transaction to revert due to insufficient balance
        vm.expectRevert();
        bank.permitDeposit(depositAmount, deadline, v, r, s);

        vm.stopPrank();
    }

    // Test incorrect nonce should fail
    function testPermitDeposit_incorrectNonce() public {
        uint256 depositAmount = 100 * 10 ** myToken.decimals();
        address user = vm.addr(userPrivateKey);
        myToken.transfer(user, 1000 * 10 ** myToken.decimals());

        // Start pranking user1 (this simulates transactions from user1)
        vm.startPrank(user);

        // Simulate user signing a permit for the bank to spend tokens
        uint256 incorrectNonce = myToken.nonces(user) + 1;  // Use an incorrect nonce
        uint256 deadline = block.timestamp + 1 days;

        // Generate the permit signature with the incorrect nonce
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, keccak256(abi.encodePacked(
            "\x19\x01",
            myToken.DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                user,
                address(bank),
                depositAmount,
                incorrectNonce,  // Incorrect nonce
                deadline
            ))
        )));

        // Expect the transaction to revert due to invalid signature (nonce mismatch)
        vm.expectRevert();
        bank.permitDeposit(depositAmount, deadline, v, r, s);

        vm.stopPrank();
    }

}
