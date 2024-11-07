## Test Result
```
Ran 5 tests for test/SimpleNFTMarketTest.t.sol:SimpleNFTMarketTest
[PASS] testClaimNFT() (gas: 214505)
[PASS] testFailClaimNFT_NotWhiteListed() (gas: 195681)
[PASS] testFailListNFT_NotOwner() (gas: 23974)
[PASS] testListNFT() (gas: 96735)
[PASS] testMulticallPermitandClaim() (gas: 210499)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 5.68ms (3.93ms CPU time)
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
