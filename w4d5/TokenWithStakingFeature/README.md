## Test
```
Ran 11 tests for test/Staking.t.sol:StakingTest
[PASS] testClaimRewardsAfterOneDay() (gas: 200513)
[PASS] testClaimRewardsMultipleDays() (gas: 200588)
[PASS] testConvertEsRNTAfterUnlock() (gas: 173292)
[PASS] testConvertEsRNTwithMultipleMaturityDates() (gas: 255371)
[PASS] testEarlyEsRNTConversionWithPenalty() (gas: 173600)
[PASS] testMultipleUsersStakeAndClaim() (gas: 337132)
[PASS] testStake() (gas: 79109)
[PASS] testUnstake() (gas: 63088)
[PASS] testUnstakeAfterClaimingRewards() (gas: 162985)
[PASS] testUnstakeAndPartialClaimRewards() (gas: 256107)
[PASS] testUnstakePartial() (gas: 82786)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 978.17µs (1.66ms CPU time)
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
