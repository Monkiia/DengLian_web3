## Test

```
Ran 12 tests for test/Staking.t.sol:StakingTest
[PASS] testClaimRewardsAfterOneDay() (gas: 181623)
[PASS] testClaimRewardsMultipleDays() (gas: 181695)
[PASS] testConvertEsRNTwithMultipleMaturityDates() (gas: 216748)
[PASS] testEarlyEsRNTConversionWithPenalty() (gas: 175199)
[PASS] testLateEsRNTConversionWithPenalty() (gas: 174938)
[PASS] testMultipleStakesAndThenClaim() (gas: 189070)
[PASS] testMultipleUsersStakeAndClaim() (gas: 299321)
[PASS] testStake() (gas: 101449)
[PASS] testUnstake() (gas: 83536)
[PASS] testUnstakeAfterClaimingRewards() (gas: 162020)
[PASS] testUnstakeAndPartialClaimRewards() (gas: 217088)
[PASS] testUnstakePartial() (gas: 108346)
Suite result: ok. 12 passed; 0 failed; 0 skipped; finished in 1.51ms (2.08ms CPU time)
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
