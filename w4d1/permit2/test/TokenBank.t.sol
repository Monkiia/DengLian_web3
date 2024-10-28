// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {MyPermitToken} from "../src/Token.sol";
import {ISignatureTransfer} from "@uniswap/permit2/interfaces/ISignatureTransfer.sol";
import {SignatureTransfer} from "@uniswap/permit2/SignatureTransfer.sol";
import {Permit2} from "@uniswap/permit2/Permit2.sol";

contract TokenBankTest is Test {
    TokenBank public bank;
    MyPermitToken public token;
    ISignatureTransfer public permit2;
    
    uint256 constant PRIVATE_KEY = 0x1234;
    address user;
    bytes32 public constant _PERMIT_TRANSFER_FROM_TYPEHASH = keccak256(
        "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
    );
    bytes32 public constant _TOKEN_PERMISSIONS_TYPEHASH = keccak256("TokenPermissions(address token,uint256 amount)");

    function setUp() public {
        permit2 = ISignatureTransfer(address(new Permit2()));
        token = new MyPermitToken();
        bank = new TokenBank(address(token), address(permit2));
        
        user = vm.addr(PRIVATE_KEY);
        console2.log("User initialized: address", vm.toString(user));
        token.transfer(user, 1000e18);
        
        vm.startPrank(user);
        token.approve(address(permit2), type(uint256).max);
        vm.stopPrank();
    }

    function testDepositWithPermit2() public {
        vm.startPrank(user);
        
        uint256 depositAmount = 100e18;
        uint256 nonce = 0;
        uint256 deadline = block.timestamp + 1 days;

        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({
                token: address(token),
                amount: depositAmount
            }),
            nonce: nonce,
            deadline: deadline
        });
        
        ISignatureTransfer.SignatureTransferDetails memory transferDetails = 
            ISignatureTransfer.SignatureTransferDetails({
                to: address(bank),
                requestedAmount: depositAmount
            });

        bytes memory sig = getPermitSignature(
            permit,
            transferDetails,
            PRIVATE_KEY,
            permit2.DOMAIN_SEPARATOR(),
            address(bank)
        );

        try bank.depositWithPermit2(
            depositAmount,
            deadline,
            nonce,
            sig
        ) {
            console2.log("\nDeposit succeeded");
            assertEq(token.balanceOf(address(bank)), depositAmount);
            assertEq(bank.balanceOf(user), depositAmount);
        } catch (bytes memory lowLevelData) {
            if (lowLevelData.length >= 4) {
                bytes4 selector = bytes4(lowLevelData);
                console2.log("\nError details:");
                console2.log("Selector:", vm.toString(bytes32(selector)));
                if (selector == bytes4(keccak256("InvalidSigner()"))) {
                    console2.log("Invalid signer error");
                }
            }
            console2.log("Raw error data:");
            console2.logBytes(lowLevelData);
            revert("Deposit failed");
        }

        vm.stopPrank();
    }

    function getPermitSignature(
        ISignatureTransfer.PermitTransferFrom memory permit,
        ISignatureTransfer.SignatureTransferDetails memory transferDetails,
        uint256 privateKey,
        bytes32 domainSeparator,
        address spender
    ) internal pure returns (bytes memory sig) {
        console2.log("Spender = ", vm.toString(spender));
        bytes32 tokenPermissionsHash = _hashTokenPermissions(permit.permitted);
        bytes32 dataHash = keccak256(
            abi.encode(_PERMIT_TRANSFER_FROM_TYPEHASH, tokenPermissionsHash, spender, permit.nonce, permit.deadline)
        );
        bytes32 msgHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, dataHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        sig = abi.encodePacked(r, s, v);
        console2.log("TokenPermissionsHash:", vm.toString(tokenPermissionsHash));
        console2.log("DataHash:", vm.toString(dataHash));
        console2.log("MsgHash:", vm.toString(msgHash));
        console2.log("DomainSeparator:", vm.toString(domainSeparator));

        console2.log("Dude, let's reverifyhere");
        address signer = ecrecover(msgHash, v, r, s);
        console2.log("Signer address:", vm.toString(signer));
        console2.log("Spender address:", vm.toString(spender));
    }


    function _hashTokenPermissions(ISignatureTransfer.TokenPermissions memory permitted)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_TOKEN_PERMISSIONS_TYPEHASH, permitted));
    }
}