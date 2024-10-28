## Integration Test Result 


```
[PASS] testDepositWithPermit2() (gas: 136923)
Logs:
  User initialized: address 0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD
  Spender =  0xF62849F9A0B5Bf2913b396098F7c7019b51A820a
  TokenPermissionsHash: 0x4501ee87d603947115ff850f4e6cf265bafb6d06b9023b28e22a15d28bf83350
  DataHash: 0x7cde3169bf32a73da87a9bf8765d5300445f5b105d9382645b8585d24952d5e5
  MsgHash: 0x4c537e9040bf870a25a8b634a4de15d814df49c0e08fce37410912b89d5322f3
  DomainSeparator: 0x01eadfe56143d8d1f420bcedaec8631185e5b833c351845caa4803a35fb9837a
  Dude, let's reverifyhere
  Signer address: 0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD
  Spender address: 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a
  MsgSender address =  0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD
  Start verifying Signature verified
  Signature verified
  
Deposit succeeded

Traces:
  [136923] TokenBankTest::testDepositWithPermit2()
    ├─ [0] VM::startPrank(0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD)
    │   └─ ← [Return] 
    ├─ [308] Permit2::DOMAIN_SEPARATOR() [staticcall]
    │   └─ ← [Return] 0x01eadfe56143d8d1f420bcedaec8631185e5b833c351845caa4803a35fb9837a
    ├─ [0] VM::toString(TokenBank: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a]) [staticcall]
    │   └─ ← [Return] "0xF62849F9A0B5Bf2913b396098F7c7019b51A820a"
    ├─ [0] console::log("Spender = ", "0xF62849F9A0B5Bf2913b396098F7c7019b51A820a") [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::sign("<pk>", 0x4c537e9040bf870a25a8b634a4de15d814df49c0e08fce37410912b89d5322f3) [staticcall]
    │   └─ ← [Return] 27, 0x8e507868b38b703435eed976a755a1865eb3fdeb9175c8ed21f0cdd701919b02, 0x2e63e81fbd4b969f296e289f1df2df8033e05e136306237c29f2ac8dcfa946d5
    ├─ [0] VM::toString(0x4501ee87d603947115ff850f4e6cf265bafb6d06b9023b28e22a15d28bf83350) [staticcall]
    │   └─ ← [Return] "0x4501ee87d603947115ff850f4e6cf265bafb6d06b9023b28e22a15d28bf83350"
    ├─ [0] console::log("TokenPermissionsHash:", "0x4501ee87d603947115ff850f4e6cf265bafb6d06b9023b28e22a15d28bf83350") [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::toString(0x7cde3169bf32a73da87a9bf8765d5300445f5b105d9382645b8585d24952d5e5) [staticcall]
    │   └─ ← [Return] "0x7cde3169bf32a73da87a9bf8765d5300445f5b105d9382645b8585d24952d5e5"
    ├─ [0] console::log("DataHash:", "0x7cde3169bf32a73da87a9bf8765d5300445f5b105d9382645b8585d24952d5e5") [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::toString(0x4c537e9040bf870a25a8b634a4de15d814df49c0e08fce37410912b89d5322f3) [staticcall]
    │   └─ ← [Return] "0x4c537e9040bf870a25a8b634a4de15d814df49c0e08fce37410912b89d5322f3"
    ├─ [0] console::log("MsgHash:", "0x4c537e9040bf870a25a8b634a4de15d814df49c0e08fce37410912b89d5322f3") [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::toString(0x01eadfe56143d8d1f420bcedaec8631185e5b833c351845caa4803a35fb9837a) [staticcall]
    │   └─ ← [Return] "0x01eadfe56143d8d1f420bcedaec8631185e5b833c351845caa4803a35fb9837a"
    ├─ [0] console::log("DomainSeparator:", "0x01eadfe56143d8d1f420bcedaec8631185e5b833c351845caa4803a35fb9837a") [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] console::log("Dude, let's reverifyhere") [staticcall]
    │   └─ ← [Stop] 
    ├─ [3000] PRECOMPILES::ecrecover(0x4c537e9040bf870a25a8b634a4de15d814df49c0e08fce37410912b89d5322f3, 27, 64370603296310427943531054391625637368301670631813854131971350156685910055682, 20982910955089234381858940173558138654956455111602735307514071191158205794005) [staticcall]
    │   └─ ← [Return] 0x000000000000000000000000cf03dd0a894ef79cb5b601a43c4b25e3ae4c67ed
    ├─ [0] VM::toString(0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD) [staticcall]
    │   └─ ← [Return] "0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD"
    ├─ [0] console::log("Signer address:", "0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD") [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::toString(TokenBank: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a]) [staticcall]
    │   └─ ← [Return] "0xF62849F9A0B5Bf2913b396098F7c7019b51A820a"
    ├─ [0] console::log("Spender address:", "0xF62849F9A0B5Bf2913b396098F7c7019b51A820a") [staticcall]
    │   └─ ← [Stop] 
    ├─ [91139] TokenBank::depositWithPermit2(100000000000000000000 [1e20], 86401 [8.64e4], 0, 0x8e507868b38b703435eed976a755a1865eb3fdeb9175c8ed21f0cdd701919b022e63e81fbd4b969f296e289f1df2df8033e05e136306237c29f2ac8dcfa946d51b)
    │   ├─ [0] console::log("MsgSender address = ", 0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD) [staticcall]
    │   │   └─ ← [Stop] 
    │   ├─ [66797] Permit2::permitTransferFrom(PermitTransferFrom({ permitted: TokenPermissions({ token: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, amount: 100000000000000000000 [1e20] }), nonce: 0, deadline: 86401 [8.64e4] }), SignatureTransferDetails({ to: 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a, requestedAmount: 100000000000000000000 [1e20] }), 0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD, 0x8e507868b38b703435eed976a755a1865eb3fdeb9175c8ed21f0cdd701919b022e63e81fbd4b969f296e289f1df2df8033e05e136306237c29f2ac8dcfa946d51b)
    │   │   ├─ [0] console::log("Start verifying Signature verified") [staticcall]
    │   │   │   └─ ← [Stop] 
    │   │   ├─ [3000] PRECOMPILES::ecrecover(0x4c537e9040bf870a25a8b634a4de15d814df49c0e08fce37410912b89d5322f3, 27, 64370603296310427943531054391625637368301670631813854131971350156685910055682, 20982910955089234381858940173558138654956455111602735307514071191158205794005) [staticcall]
    │   │   │   └─ ← [Return] 0x000000000000000000000000cf03dd0a894ef79cb5b601a43c4b25e3ae4c67ed
    │   │   ├─ [0] console::log("Signature verified") [staticcall]
    │   │   │   └─ ← [Stop] 
    │   │   ├─ [31907] MyPermitToken::transferFrom(0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD, TokenBank: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], 100000000000000000000 [1e20])
    │   │   │   ├─ emit Transfer(from: 0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD, to: TokenBank: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], value: 100000000000000000000 [1e20])
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 
    ├─ [0] console::log("\nDeposit succeeded") [staticcall]
    │   └─ ← [Stop] 
    ├─ [541] MyPermitToken::balanceOf(TokenBank: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a]) [staticcall]
    │   └─ ← [Return] 100000000000000000000 [1e20]
    ├─ [0] VM::assertEq(100000000000000000000 [1e20], 100000000000000000000 [1e20]) [staticcall]
    │   └─ ← [Return] 
    ├─ [403] TokenBank::balanceOf(0xCf03Dd0a894Ef79CB5b601A43C4b25E3Ae4c67eD) [staticcall]
    │   └─ ← [Return] 100000000000000000000 [1e20]
    ├─ [0] VM::assertEq(100000000000000000000 [1e20], 100000000000000000000 [1e20]) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return] 
    └─ ← [Return] 

```