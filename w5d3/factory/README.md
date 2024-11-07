## Result (See upgrade deploy script)
```
== Logs ==
  Upgrading contracts with address: 0xb25FeDED22519Ae27CEE41de48a10Be889D4CBfb
  Proxy address: 0x7b9Bf33e0F24d6eC6Ab9613bDf90eA81592CEF3B
  V2 implementation: 0x3578feF672BF8e4f72bC949716f951E6655278C1
  Token implementation: 0x2502E528423da03C29CFD8B752a3D41167b0BaC6
  Current implementation: 0x50dD6A9Cae958F860d780A6099bf8099C8273093
  Current owner from storage: 0xb25FeDED22519Ae27CEE41de48a10Be889D4CBfb
  Proxy upgraded to V2 implementation
  V2 implementation initialized
  Token implementation set
  
=== Upgrade Summary ===
  Network: 11155111
  Proxy Address: 0x7b9Bf33e0F24d6eC6Ab9613bDf90eA81592CEF3B
  Previous Implementation: 0x50dD6A9Cae958F860d780A6099bf8099C8273093
  New Implementation (V2): 0x3578feF672BF8e4f72bC949716f951E6655278C1
  Token Implementation: 0x2502E528423da03C29CFD8B752a3D41167b0BaC6
```

## Test
```
Ran 2 tests for test/InscriptionFactory.t.sol:InscriptionTest
[PASS] testFactoryUpgradeV1ToV2() (gas: 1149019)
[PASS] testMintingLimits() (gas: 273041)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 5.42ms (892.58µs CPU time)
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
