## Test Result
test in local anvil env
result
```
[PASS] testReadLocks() (gas: 130786)
Logs:
  Lock 0
  User: 0x0000000000000000000000000000000000000001
  StartTime: 3461581648
  Amount: 1000000000000000000
  ----------------
  Lock 1
  User: 0x0000000000000000000000000000000000000002
  StartTime: 3461581647
  Amount: 2000000000000000000
  ----------------
  Lock 2
  User: 0x0000000000000000000000000000000000000003
  StartTime: 3461581646
  Amount: 3000000000000000000
  ----------------
  Lock 3
  User: 0x0000000000000000000000000000000000000004
  StartTime: 3461581645
  Amount: 4000000000000000000
  ----------------
  Lock 4
  User: 0x0000000000000000000000000000000000000005
  StartTime: 3461581644
  Amount: 5000000000000000000
  ----------------
  Lock 5
  User: 0x0000000000000000000000000000000000000006
  StartTime: 3461581643
  Amount: 6000000000000000000
  ----------------
  Lock 6
  User: 0x0000000000000000000000000000000000000007
  StartTime: 3461581642
  Amount: 7000000000000000000
  ----------------
  Lock 7
  User: 0x0000000000000000000000000000000000000008
  StartTime: 3461581641
  Amount: 8000000000000000000
  ----------------
  Lock 8
  User: 0x0000000000000000000000000000000000000009
  StartTime: 3461581640
  Amount: 9000000000000000000
  ----------------
  Lock 9
  User: 0x000000000000000000000000000000000000000A
  StartTime: 3461581639
  Amount: 10000000000000000000
  ----------------
  Lock 10
  User: 0x000000000000000000000000000000000000000b
  StartTime: 3461581638
  Amount: 11000000000000000000
  ----------------

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
