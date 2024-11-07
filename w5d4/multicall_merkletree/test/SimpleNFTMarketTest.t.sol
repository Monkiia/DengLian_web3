// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SimpleNFTMarket.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract MockToken is ERC20Permit {
    constructor() ERC20("MockToken", "MTK") ERC20Permit("MockToken") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}

contract SimpleNFTMarketTest is Test {
    SimpleNFTMarket public market;
    MockNFT public nft;
    MockToken public token;
    address public owner;
    address public buyer;

    bytes32 public merkleRoot;
    bytes32[] public proof;
    uint256 buyer_private_key = 0x1234567890123456789012345678901234567890123456789012345678901234;
    error NotInWhitelist();

    function setUp() public {
        owner = address(this); // 测试合约地址为NFT拥有者
        buyer = vm.addr(buyer_private_key); // 0x2e988A386a799F506693793c6A5AF6B54dfAaBfB
        emit log_address(buyer);

        nft = new MockNFT();
        token = new MockToken();

        // 设置白名单Merkle Root和Proof
        merkleRoot = 0x619cd49028ea1a4308b940ebd501fec7f829d31b988f0bf5ccb6252f968a1311;
        proof = new bytes32[](1);
        proof[0] = 0xb6979620706f8c652cfb6bf6e923f5156eadd5abaf4022a0b19d52ada089475f;

        // 部署市场合约
        market = new SimpleNFTMarket(merkleRoot, address(nft));

        // 铸造NFT并分配给合约拥有者
        nft.mint(owner, 1);
        nft.mint(owner, 2);

        // 铸造代币并分配给买家
        token.transfer(buyer, 100 * 10 ** token.decimals());
    }

    function testMulticallPermitandClaim() public {
        // 上架NFT
        nft.approve(address(market), 1);
        market.listNFT(1, 50 * 10 ** token.decimals());

        // 设置permit参数
        uint256 value = 50 * 10 ** token.decimals();
        uint256 deadline = block.timestamp + 1 days;

        // 获取buyer的nonce
        uint256 nonce = token.nonces(buyer);

        // 生成签名
        bytes32 DOMAIN_SEPARATOR = token.DOMAIN_SEPARATOR();
        bytes32 PERMIT_TYPEHASH = keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                buyer,
                address(market),
                value,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // 使用买家的私钥对 digest 签名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyer_private_key, digest);

        // 构建 permitPrePay 和 claimNFT 的多重调用数据
        bytes memory permitData = abi.encodeWithSelector(
            market.permitPrePay.selector,
            address(token),
            value,
            deadline,
            v,
            r,
            s
        );

        bytes memory claimData = abi.encodeWithSelector(
            market.claimNFT.selector,
            address(token),
            1,
            proof
        );

        // 使用buyer地址模拟 multicall
        vm.startPrank(buyer);
        bytes[] memory callData = new bytes[](2);
        callData[0] = permitData;
        callData[1] = claimData;
        market.multicall(callData);
        vm.stopPrank();

        // 验证NFT是否已转移给买家
        assertEq(nft.ownerOf(1), buyer);
    }


    function testListNFT() public {
        nft.approve(address(market), 1);
        market.listNFT(1, 50 * 10 ** token.decimals());

        (uint256 price, bool isListed) = market.listedNFTs(1);
        assertEq(price, 50 * 10 ** token.decimals());
        assertTrue(isListed);
    }

    function testFailListNFT_NotOwner() public {
        // buyer 不是NFT的所有者，应该无法上架NFT
        vm.startPrank(buyer);
        market.listNFT(1, 50 * 10 ** token.decimals());
        vm.stopPrank();
    }

    function testClaimNFT() public {
        // 上架NFT
        nft.approve(address(market), 1);
        market.listNFT(1, 50 * 10 ** token.decimals());

        // buyer 通过permit授权
        uint256 value = 50 * 10 ** token.decimals();
        uint256 deadline = block.timestamp + 1 days;

        // 构建DOMAIN_SEPARATOR和PERMIT_TYPEHASH的消息结构
        bytes32 DOMAIN_SEPARATOR = token.DOMAIN_SEPARATOR();
        bytes32 PERMIT_TYPEHASH = keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

        // 获取buyer的nonce
        uint256 nonce = token.nonces(buyer);

        // 构建签名的消息哈希
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                buyer,
                address(market),
                value,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // 使用buyer的私钥对digest签名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyer_private_key, digest);

        vm.prank(buyer);
        market.permitPrePay(token, value, deadline, v, r, s);

        // 验证购买
        vm.startPrank(buyer);
        bool result = market.verifyWhiteListedOrNot(buyer, proof);
        console.log("result of verifyWhiteListedOrNot: %s", result);
        market.claimNFT(token, 1, proof);
        vm.stopPrank();

        // 验证NFT转移
        assertEq(nft.ownerOf(1), buyer);
        (, bool isListed) = market.listedNFTs(1);
        assertFalse(isListed);
    }

    function testFailClaimNFT_NotWhiteListed() public {
        // 上架NFT
        nft.approve(address(market), 1);
        market.listNFT(1, 50 * 10 ** token.decimals());

        // 非白名单用户试图购买
        uint256 nonWhiteListedUser_private_key = 0x4567890123456789012345678901234567890123456789012345678901234567;
        address nonWhiteListedUser = vm.addr(nonWhiteListedUser_private_key);

        token.transfer(nonWhiteListedUser, 100 * 10 ** token.decimals());

        uint256 value = 50 * 10 ** token.decimals();
        uint256 deadline = block.timestamp + 1 days;

        // 构建DOMAIN_SEPARATOR和PERMIT_TYPEHASH的消息结构
        bytes32 DOMAIN_SEPARATOR = token.DOMAIN_SEPARATOR();
        bytes32 PERMIT_TYPEHASH = keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

        // 获取buyer的nonce
        uint256 nonce = token.nonces(nonWhiteListedUser);

        // 构建签名的消息哈希
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                nonWhiteListedUser,
                address(market),
                value,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // 使用buyer的私钥对digest签名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(nonWhiteListedUser_private_key, digest);

        vm.prank(nonWhiteListedUser);
        market.permitPrePay(token, value, deadline, v, r, s);

        // 购买应该失败
        vm.prank(nonWhiteListedUser);
        vm.expectRevert(NotInWhitelist.selector);  // 使用错误选择器
        market.claimNFT(token, 1, proof);
    }
}
