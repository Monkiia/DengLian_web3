## Test
```
[PASS] test_ClaimWithZeroRewards() (gas: 87586)
[PASS] test_MultipleUnstakeWithinBalance() (gas: 103468)
[PASS] test_ReentrancyProtection() (gas: 259859)
[PASS] test_RevertInsufficientBalance() (gas: 78930)
[PASS] test_RevertUnstakeWithoutStake() (gas: 21177)
[PASS] test_RevertZeroStake() (gas: 20929)
[PASS] test_RevertZeroUnstake() (gas: 78688)
[PASS] test_RewardsDistributionMultipleStakers() (gas: 296451)
[PASS] test_RewardsForSingleStaker() (gas: 189839)
[PASS] test_StakeUnstakeRewardScenario() (gas: 213501)
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
