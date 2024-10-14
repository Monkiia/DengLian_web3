// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts@4.4.0/token/ERC20/ERC20.sol";

contract DLCCoin is ERC20 {
    constructor() ERC20("DengLianCoin", "DLC") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
}

contract tokenBank {
    mapping (address => uint) private balances;
    IERC20 private DLCToken;  // Declare DLCCoin as an ERC20 token

    // Constructor to initialize the DLCCoin contract address
    constructor(address _DLCCoinAddress) {
        DLCToken = IERC20(_DLCCoinAddress);  // Initialize with the address of DLCCoin contract
    }

    function deposit(uint256 _amount) public payable{
        bool success = DLCToken.transferFrom(msg.sender, address(this), _amount);
        require(success, 'Could not transfer funds');
        balances[msg.sender] += _amount;
        DLCToken.approve(msg.sender, balances[msg.sender]);
    }

    function withdrawl(uint256 _amount) public payable {
        uint current_balance = balances[msg.sender];
        require(current_balance >= _amount, "Not enough balance");
        balances[msg.sender] -= _amount;
        DLCToken.transfer(msg.sender, current_balance);
    }

    // Function to check a user's bank balance
    function getBalance(address _account) public view returns (uint256) {
        return balances[_account];
    }
}
