// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title RenftMarket
 * @dev NFT租赁市场合约
 */
contract RenftMarket is EIP712 {
    event BorrowNFT(address indexed taker, address indexed maker, bytes32 orderHash, uint256 collateral);
    event OrderCanceled(address indexed maker, bytes32 orderHash);

    mapping(bytes32 => BorrowOrder) public orders; // 已租赁订单
    mapping(bytes32 => bool) public canceledOrders; // 已取消的挂单

    constructor() EIP712("RenftMarket", "1") { }

    struct RentoutOrder {
        address maker; // 出租方地址
        address nft_ca; // NFT合约地址
        uint256 token_id; // NFT tokenId
        uint256 daily_rent; // 每日租金
        uint256 max_rental_duration; // 最大租赁时长
        uint256 min_collateral; // 最小抵押
        uint256 list_endtime; // 挂单结束时间
    }

    struct BorrowOrder {
        address taker; // 租方人地址
        uint256 collateral; // 抵押
        uint256 start_time; // 租赁开始时间，方便计算租金
        RentoutOrder rentinfo; // 租赁订单
    }

    /**
     * @notice 租赁NFT
     * @dev 验证签名后，将NFT从出租人转移到租户，并存储订单信息
     */
    function borrow(RentoutOrder calldata order, bytes calldata makerSignature) external payable {
        require(block.timestamp <= order.list_endtime, "Order expired");
        require(msg.value >= order.min_collateral, "Insufficient collateral");
        
        bytes32 orderHashValue = orderHash(order);
        require(!canceledOrders[orderHashValue], "Order canceled");
        require(verifySignature(order.maker, orderHashValue, makerSignature), "Invalid signature");

        IERC721 nft = IERC721(order.nft_ca);
        require(nft.ownerOf(order.token_id) == order.maker, "Maker does not own the NFT");

        nft.transferFrom(order.maker, msg.sender, order.token_id);

        orders[orderHashValue] = BorrowOrder({
            taker: msg.sender,
            collateral: msg.value,
            start_time: block.timestamp,
            rentinfo: order
        });

        emit BorrowNFT(msg.sender, order.maker, orderHashValue, msg.value);
    }

    /**
     * @notice 取消订单
     * @dev 标记订单已取消，防止重复使用
     */
    function cancelOrder(RentoutOrder calldata order, bytes calldata makerSignature) external {
        bytes32 orderHashValue = orderHash(order);
        require(!canceledOrders[orderHashValue], "Order already canceled");
        require(verifySignature(order.maker, orderHashValue, makerSignature), "Invalid signature");
        require(order.maker == msg.sender, "Only maker can cancel");

        canceledOrders[orderHashValue] = true;
        
        emit OrderCanceled(order.maker, orderHashValue);
    }

    /**
     * @notice 计算订单哈希
     * @param order 租赁订单信息
     * @return 订单的哈希值
     */
    function orderHash(RentoutOrder calldata order) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            keccak256("RentoutOrder(address maker,address nft_ca,uint256 token_id,uint256 daily_rent,uint256 max_rental_duration,uint256 min_collateral,uint256 list_endtime)"),
            order.maker,
            order.nft_ca,
            order.token_id,
            order.daily_rent,
            order.max_rental_duration,
            order.min_collateral,
            order.list_endtime
        )));
    }

    /**
     * @notice 验证签名
     * @param signer 订单签名人
     * @param hash 订单哈希
     * @param signature 签名
     * @return 是否通过验证
     */
    function verifySignature(address signer, bytes32 hash, bytes memory signature) internal pure returns (bool) {
        return ECDSA.recover(hash, signature) == signer;
    }
}
