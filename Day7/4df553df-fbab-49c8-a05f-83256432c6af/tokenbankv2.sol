// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./tokenbank.sol";

interface IERC20Receiver {
    function tokensReceived(address from, uint256 amount, bytes calldata data) external payable;
}

contract DLCCoinV2 is ERC20 {
    using Address for address;
    event LogErrorString(string reason); 

    constructor() ERC20("DengLianCoinV2", "DLCV2") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }

    // 重写 transfer 函数
    function transfer(address to, uint256 value) public virtual override returns (bool) {
        super.transfer(to, value);
        if (to.isContract()) {
            // 使用 try-catch 处理 tokensReceived 调用
            try IERC20Receiver(to).tokensReceived(_msgSender(), value, bytes("")) {
            } catch {
                // 如果目标合约没有实现 tokensReceived 或调用失败
                revert("Receiver contract does not implement tokensReceived");
            }
        }
        return true;
    }

    // 重写 transferFrom 函数
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        super.transferFrom(from, to, amount);
        // 检查接收者是否为合约地址
        if (to.isContract()) {
            // 使用 try-catch 处理 tokensReceived 调用
            try IERC20Receiver(to).tokensReceived(from, amount, bytes("")) {
                // tokensReceived 调用成功
            } catch {
                // 如果目标合约没有实现 tokensReceived 或调用失败
                revert("Receiver contract does not implement tokensReceived");
            }
        }

        return true;
    }

    // 实现 transferWithCallback 函数
    function transferWithCallback(
        address to,
        uint256 amount,
        bytes calldata data
    ) public returns (bool) {
        _transfer(_msgSender(), to, amount);

        if (to.isContract()) {
            // 调用合约的 tokensReceived 方法
            try IERC20Receiver(to).tokensReceived(_msgSender(), amount, data) {
                // tokensReceived 调用成功
            } catch {
                revert("Receiver contract does not implement tokensReceived");
            }
        }

        return true;
    }
}

contract tokenBankV2 is tokenBank, IERC20Receiver {
    using Address for address;

    // 构造函数，接收代币合约的地址
    constructor(address _DLCTokenAddress) tokenBank(_DLCTokenAddress) {
        // 这里可以执行 tokenBankV2 的初始化逻辑
    }

    function tokensReceived(address sender, uint256 _amount, bytes calldata data) public payable {
        require(msg.sender == address(DLCToken), "Only token contract can call this callback function");
        balances[sender] += _amount;
        DLCToken.approve(sender, balances[sender]);
    }

}

