// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    uint256 public threshold;
    uint256 public totalDeposits;

    event Deposit(address indexed user, uint256 amount);
    event TransferToOwner(uint256 amount);

    constructor(uint256 _threshold) {
        owner = msg.sender;
        threshold = _threshold;
    }

    function deposit() public payable {
        require(msg.value > 0, "Must deposit positive amount");
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function checkUpkeep(bytes calldata) external view returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = totalDeposits >= threshold;
    }

    function performUpkeep(bytes calldata) external {
        require(totalDeposits >= threshold, "Threshold not reached");

        uint256 transferAmount = totalDeposits / 2;
        totalDeposits -= transferAmount;
        payable(owner).transfer(transferAmount);

        emit TransferToOwner(transferAmount);
    }

    function setThreshold(uint256 _newThreshold) external {
        require(msg.sender == owner, "Only owner can set threshold");
        threshold = _newThreshold;
    }

    receive() external payable {
        deposit();
    }
}
