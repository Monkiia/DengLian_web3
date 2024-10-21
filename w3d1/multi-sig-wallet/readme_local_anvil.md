// 部署合约到本地anvil 环境
forge create --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 src/MultiSigWallet.sol:MultiSigWallet --constructor-args "[0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,0x70997970C51812dc3A010C7d01b50e0d17dc79C8,0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC]"


Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Transaction hash: 0x9213f116cdb8f5c844b18a3bd7b38f18c21193eb482370f058d00f952f21f854


// 一个owner propose and approve (success)
cast send --rpc-url http://127.0.0.1:8545 --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --unlocked 0x5FbDB2315678afecb367f032d93F642f64180aa3 "propose(address,uint256)" 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC 1000000

// 转点钱给合约账户 (success)
cast send --rpc-url http://127.0.0.1:8545 --from 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 --unlocked --value 1ether 0x5FbDB2315678afecb367f032d93F642f64180aa3

// 一个owner approve thus 合约自动执行 (success)
cast send --rpc-url http://127.0.0.1:8545 --from 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 --unlocked 0x5FbDB2315678afecb367f032d93F642f64180aa3 "approve(uint256)" 0

// 随便找个账户再执行一下 会报错(failure)
cast send --rpc-url http://127.0.0.1:8545 --from 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 --unlocked 0x5FbDB2315678afecb367f032d93F642f64180aa3 "execute(uint256)" 0
with error code
```
server returned an error response: error code 3: execution reverted: revert: Proposal already executed, data: "0x08c379a00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001950726f706f73616c20616c726561647920657865637574656400000000000000"
```