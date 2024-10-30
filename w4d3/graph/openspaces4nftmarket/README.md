
NFTMarket Address: 0x06F9C30571f1a174ca6642D753a468481c9A8E7a


GraphQL endpoint: https://api.studio.thegraph.com/query/93114/openspaces4nftmarket/version/latest


There are three orders, one listing, one canceled, one fullfilled
## GraphQL OrderBooks
### input 
```
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query": "{ orderBooks(first: 5) { id nft tokenId seller blockNumber blockTimestamp cancelTxHash deadline filledTxHash payToken price transactionHash} }", "operationName": "Subgraphs", "variables": {}}' \
  https://api.studio.thegraph.com/query/93114/openspaces4nftmarket/version/latest
```
### output
```
  "data": {
    "orderBooks": [
      {
        "id": "0x259c8966bf486b738dd345f662d5ac27f1d187aae161d6f572bee3500f3687b8",
        "nft": "0x671bdbe5e3c6b95e680a95069cb6d03d5371f08a",
        "tokenId": "2",
        "seller": "0xb25feded22519ae27cee41de48a10be889d4cbfb",
        "payToken": "0xc5562ba64c00e0df7bf2355860de29f996c44e25",
        "blockNumber": "6975477",
        "blockTimestamp": "1730276976",
        "cancelTxHash": "0x00000000",
        "filledTxHash": "0xff44c7acb26c68dafa6193798b06311563aadaa62328181f07ff518a7c6d1b65",
        "deadline": "1730678400",
        "price": "100",
        "transactionHash": "0x864aaf6ddbf1aedb556457f56dd308ec32a50d83c49abb7b7fbd59abd99b966b"
      },
      {
        "id": "0x45d28d3d058c77bddc31070275a9c93ad2f5f50750363db77fdeb49c87b95d35",
        "nft": "0x671bdbe5e3c6b95e680a95069cb6d03d5371f08a",
        "tokenId": "1",
        "seller": "0xb25feded22519ae27cee41de48a10be889d4cbfb",
        "payToken": "0xc5562ba64c00e0df7bf2355860de29f996c44e25",
        "blockNumber": "6975477",
        "blockTimestamp": "1730276976",
        "cancelTxHash": "0x17ab7151d3e928ac71e85ab5a5976afe8f782caa024e7419da43ddaea7a63614",
        "filledTxHash": "0x00000000",
        "deadline": "1730678400",
        "price": "100",
        "transactionHash": "0x9c7ee0ff1dab2b8bca31f2bc31046d7f82624a7eeaad80f61a6b19857a1a59e3"
      },
      {
        "id": "0xeca1d22e19f55ecb69182b45cd8d35c613f093df95a40da9ea0dca517613124e",
        "nft": "0x671bdbe5e3c6b95e680a95069cb6d03d5371f08a",
        "tokenId": "0",
        "seller": "0xb25feded22519ae27cee41de48a10be889d4cbfb",
        "payToken": "0xc5562ba64c00e0df7bf2355860de29f996c44e25",
        "blockNumber": "6975476",
        "blockTimestamp": "1730276964",
        "cancelTxHash": "0x00000000",
        "filledTxHash": "0x00000000",
        "deadline": "1730678400",
        "price": "100",
        "transactionHash": "0x12d9fa2a9dc27ea7700ba0105485984f3d5907a3db6da4a0998937e417828fd1"
      }
    ]
  }
```

## GraphQL FilledOrder
### input
```
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query": "{ filledOrders(first: 5) { id buyer fee blockNumber transactionHash order {id } } }", "operationName": "Subgraphs", "variables": {}}' \
  https://api.studio.thegraph.com/query/93114/openspaces4nftmarket/version/latest
```
### output
```
{
  "data": {
    "filledOrders": [
      {
        "id": "0x259c8966bf486b738dd345f662d5ac27f1d187aae161d6f572bee3500f3687b8",
        "buyer": "0x5a9373964eb86e16fab9a952f9a1b083c7af90b4",
        "fee": "0",
        "blockNumber": "6975642",
        "blockTimestamp": "1730279040",
        "transactionHash": "0xff44c7acb26c68dafa6193798b06311563aadaa62328181f07ff518a7c6d1b65",
        "order": {
          "id": "0x259c8966bf486b738dd345f662d5ac27f1d187aae161d6f572bee3500f3687b8"
        }
      }
    ]
  }
}
```
