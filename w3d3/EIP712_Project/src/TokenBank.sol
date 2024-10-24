// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract tokenBank {
    IERC20 public token;
    mapping (address => uint) internal balances;
    IERC20Permit internal permitToken;
    // Constructor to initialize the DLCCoin contract address
    constructor(address _CoinAddress) {
        permitToken = IERC20Permit(_CoinAddress); 
        token = IERC20(_CoinAddress);
    }

    function deposit(uint256 _amount) public payable{
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, 'Could not transfer funds');
        balances[msg.sender] += _amount;
        token.approve(msg.sender, balances[msg.sender]);
    }

    function permitDeposit(uint256 _amount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public payable {
        // Use permit to approve the contract to spend tokens on behalf of msg.sender
        permitToken.permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);

        // After permit, transfer the tokens from the sender to this contract
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        // Update the balance of the sender
        balances[msg.sender] += _amount;
    }

    function withdrawl(uint256 _amount) public payable {
        uint current_balance = balances[msg.sender];
        require(current_balance >= _amount, "Not enough balance");
        balances[msg.sender] -= _amount;
        token.transfer(msg.sender, current_balance);
    }

    // Function to check a user's bank balance
    function getBalance(address _account) public view returns (uint256) {
        return balances[_account];
    }
}