// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address private admin;
    mapping (address => uint) private balances;
    uint[3] private topThreeAmount;             // 存储前 3 大的存款金额
    address[3] private topThreeUsers;           // 存储前 3 大存款的用户地址

    // 构造函数：在部署时，管理员地址设为部署者地址
    constructor() {
        admin = msg.sender;  // 因为其在构造函数中 msg.sender 是部署合约的地址
    }

    // 只有管理员可以调用的修饰符
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // 提币功能，只有管理员可以提取合约中的所有余额
    function withdraw() public onlyAdmin {
        // 使用 call 发送以太币
        (bool success, ) = payable(admin).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    // 存款功能，允许任何人向合约转账
    receive() external payable {
        // 更新余额
        address senderAddress = msg.sender;
        uint original_balance = balances[senderAddress];
        balances[senderAddress] += msg.value;

        // 扫描这三个topThreeAmount，若original_balance在其中，直接更新
        bool found = false;
        for (uint i = 0; i < 3; i++) {
            if (original_balance == topThreeAmount[i]) {
                topThreeAmount[i] = balances[senderAddress];
                topThreeUsers[i] = senderAddress; // 更新用户地址
                found = true;
                break;
            }
        }

        // 如果用户不在top 3中，则替换掉最小的那一个
        if (!found) {
            uint minIndex = 0;
            uint minAmount = topThreeAmount[0];

            // 找出top 3中最小的存款金额
            for (uint i = 1; i < 3; i++) {
                if (topThreeAmount[i] < minAmount) {
                    minAmount = topThreeAmount[i];
                    minIndex = i;
                }
            }

            // 如果当前用户的余额比最小值大，则替换掉最小的
            if (balances[senderAddress] > minAmount) {
                topThreeAmount[minIndex] = balances[senderAddress];
                topThreeUsers[minIndex] = senderAddress;  // 替换用户地址
            }
        }
    }

    // 获取前 3 大存款的用户和金额
    function getTopThree() public view returns (address[3] memory, uint[3] memory) {
        return (topThreeUsers, topThreeAmount);
    }

    // 查询合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

