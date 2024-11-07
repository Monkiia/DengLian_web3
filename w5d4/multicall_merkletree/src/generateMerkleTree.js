const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

// 定义白名单地址
const whitelistAddresses = [
    '0x2e988A386a799F506693793c6A5AF6B54dfAaBfB',
    '0x1234567890123456789012345678901234567890',
];

// 将每个地址哈希化以生成叶子节点
const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

// 获取Merkle树的根节点
const merkleRoot = merkleTree.getRoot().toString('hex');
console.log('Merkle Root:', `0x${merkleRoot}`);

// 为每个地址生成Merkle证明
whitelistAddresses.forEach((address, index) => {
    const proof = merkleTree.getHexProof(leafNodes[index]);
    console.log(`Proof for ${address}:`, proof);
});
