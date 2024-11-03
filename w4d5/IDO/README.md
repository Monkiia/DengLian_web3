## Test Result
```
Ran 5 tests for test/IDOContract.sol:TestIDOContract
[PASS] testEdgeCaseMaxCapExceeded() (gas: 249686)
[PASS] testFundraisingFailWithRefunds() (gas: 304749)
[PASS] testFundraisingSuccess() (gas: 476347)
[PASS] testProjectCancellation() (gas: 203054)
[PASS] testTokenClaimingWithoutContribution() (gas: 213189)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 4.45ms (2.14ms CPU time)
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
