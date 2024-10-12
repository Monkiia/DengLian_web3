// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function withdraw() external;
    receive() external payable;
    function getTopThree() external returns (address[3] memory, uint[3] memory);
    function getBalance() external returns (uint256);
}

contract Bank is IBank {
    address internal admin;
    mapping (address => uint) internal balances;
    uint[3] internal topThreeAmount;             // 存储前 3 大的存款金额
    address[3] internal topThreeUsers;           // 存储前 3 大存款的用户地址
    

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

    // internal 函数，处理存款逻辑
    function deposit(address senderAddress, uint amount) internal {
        // 更新余额
        uint original_balance = balances[senderAddress];
        balances[senderAddress] += amount;

        // 扫描 topThreeAmount，若 original_balance 在其中，直接更新
        bool found = false;
        for (uint i = 0; i < 3; i++) {
            if (original_balance == topThreeAmount[i]) {
                topThreeAmount[i] = balances[senderAddress];
                topThreeUsers[i] = senderAddress; // 更新用户地址
                found = true;
                break;
            }
        }

        // 如果用户不在 top 3 中，则替换掉最小的那一个
        if (!found) {
            uint minIndex = 0;
            uint minAmount = topThreeAmount[0];

            // 找出 top 3 中最小的存款金额
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

    // 存款功能，允许任何人向合约转账
    receive() external payable virtual {
        deposit(msg.sender, msg.value);
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

contract BigBank is Bank {
    uint constant minimal_amount = 0.001 ether;
    error InsufficientETH(uint256 requiredAmount);

    modifier depositReq() {
        if (msg.value < minimal_amount) {
            revert InsufficientETH(minimal_amount);
        }
        _;
    }

    function transferAdmin(address newAdminAddress) public onlyAdmin {
        admin = newAdminAddress;
    }

    // BigBank 会 check 资金是否大于 minimal_amount eth
    receive() external payable override depositReq {
        require(msg.value >= minimal_amount, "Need at least 0.001 ETH");
        deposit(msg.sender, msg.value);
    }
}

contract Admin {
    address private admin;
    // 构造函数：在部署时，管理员地址设为部署者地址
    constructor() {
        admin = msg.sender; 
    }
    // 只有管理员可以调用的修饰符，这里的管理员是 部署ownerable 合约的地址
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    // 合约需要能收钱 所以显式声明payable
    receive() external payable { }

    // 合约从银行取钱打到合约地址 big bank money -> contract address
    // 注意 这个取钱不是从合约地址打到合约管理员 NOT contract address -> admin address
    function withdraw(IBank bank) public onlyAdmin {
        bank.withdraw();
    }

}