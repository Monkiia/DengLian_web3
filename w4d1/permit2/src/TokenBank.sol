// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@uniswap/permit2/interfaces/ISignatureTransfer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";

contract TokenBank {
    IERC20 public immutable token;
    ISignatureTransfer public immutable permit2;
    mapping(address => uint256) public balanceOf;

    constructor(address _token, address _permit2) {
        token = IERC20(_token);
        permit2 = ISignatureTransfer(_permit2);
    }

    function depositWithPermit2(
        uint256 amount,
        uint256 deadline,
        uint256 nonce,
        bytes calldata signature
    ) external {
        ISignatureTransfer.PermitTransferFrom memory permit = 
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: address(token),
                    amount: amount
                }),
                nonce: nonce,
                deadline: deadline
            });
        
        ISignatureTransfer.SignatureTransferDetails memory transferDetails = 
            ISignatureTransfer.SignatureTransferDetails({
                to: address(this),
                requestedAmount: amount
            });
        
        console2.log("MsgSender address = ", address(msg.sender));

        permit2.permitTransferFrom(
            permit,
            transferDetails,
            msg.sender,
            signature
        );

        balanceOf[msg.sender] += amount;
    }
}