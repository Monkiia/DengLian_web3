// TODO: 配置合约ABI
export const marketABI = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"ECDSAInvalidSignature","type":"error"},{"inputs":[{"internalType":"uint256","name":"length","type":"uint256"}],"name":"ECDSAInvalidSignatureLength","type":"error"},{"inputs":[{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"ECDSAInvalidSignatureS","type":"error"},{"inputs":[],"name":"InvalidShortString","type":"error"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"StringTooLong","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"taker","type":"address"},{"indexed":true,"internalType":"address","name":"maker","type":"address"},{"indexed":false,"internalType":"bytes32","name":"orderHash","type":"bytes32"},{"indexed":false,"internalType":"uint256","name":"collateral","type":"uint256"}],"name":"BorrowNFT","type":"event"},{"anonymous":false,"inputs":[],"name":"EIP712DomainChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"maker","type":"address"},{"indexed":false,"internalType":"bytes32","name":"orderHash","type":"bytes32"}],"name":"OrderCanceled","type":"event"},{"inputs":[{"components":[{"internalType":"address","name":"maker","type":"address"},{"internalType":"address","name":"nft_ca","type":"address"},{"internalType":"uint256","name":"token_id","type":"uint256"},{"internalType":"uint256","name":"daily_rent","type":"uint256"},{"internalType":"uint256","name":"max_rental_duration","type":"uint256"},{"internalType":"uint256","name":"min_collateral","type":"uint256"},{"internalType":"uint256","name":"list_endtime","type":"uint256"}],"internalType":"struct RenftMarket.RentoutOrder","name":"order","type":"tuple"},{"internalType":"bytes","name":"makerSignature","type":"bytes"}],"name":"borrow","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"maker","type":"address"},{"internalType":"address","name":"nft_ca","type":"address"},{"internalType":"uint256","name":"token_id","type":"uint256"},{"internalType":"uint256","name":"daily_rent","type":"uint256"},{"internalType":"uint256","name":"max_rental_duration","type":"uint256"},{"internalType":"uint256","name":"min_collateral","type":"uint256"},{"internalType":"uint256","name":"list_endtime","type":"uint256"}],"internalType":"struct RenftMarket.RentoutOrder","name":"order","type":"tuple"},{"internalType":"bytes","name":"makerSignature","type":"bytes"}],"name":"cancelOrder","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"canceledOrders","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"eip712Domain","outputs":[{"internalType":"bytes1","name":"fields","type":"bytes1"},{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"version","type":"string"},{"internalType":"uint256","name":"chainId","type":"uint256"},{"internalType":"address","name":"verifyingContract","type":"address"},{"internalType":"bytes32","name":"salt","type":"bytes32"},{"internalType":"uint256[]","name":"extensions","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"maker","type":"address"},{"internalType":"address","name":"nft_ca","type":"address"},{"internalType":"uint256","name":"token_id","type":"uint256"},{"internalType":"uint256","name":"daily_rent","type":"uint256"},{"internalType":"uint256","name":"max_rental_duration","type":"uint256"},{"internalType":"uint256","name":"min_collateral","type":"uint256"},{"internalType":"uint256","name":"list_endtime","type":"uint256"}],"internalType":"struct RenftMarket.RentoutOrder","name":"order","type":"tuple"}],"name":"orderHash","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"orders","outputs":[{"internalType":"address","name":"taker","type":"address"},{"internalType":"uint256","name":"collateral","type":"uint256"},{"internalType":"uint256","name":"start_time","type":"uint256"},{"components":[{"internalType":"address","name":"maker","type":"address"},{"internalType":"address","name":"nft_ca","type":"address"},{"internalType":"uint256","name":"token_id","type":"uint256"},{"internalType":"uint256","name":"daily_rent","type":"uint256"},{"internalType":"uint256","name":"max_rental_duration","type":"uint256"},{"internalType":"uint256","name":"min_collateral","type":"uint256"},{"internalType":"uint256","name":"list_endtime","type":"uint256"}],"internalType":"struct RenftMarket.RentoutOrder","name":"rentinfo","type":"tuple"}],"stateMutability":"view","type":"function"}];

export const localMarketABI = [
    {
      "type": "constructor",
      "inputs": [],
      "stateMutability": "nonpayable"
    },
    {
      "type": "function",
      "name": "borrow",
      "inputs": [
        {
          "name": "order",
          "type": "tuple",
          "internalType": "struct RenftMarket.RentoutOrder",
          "components": [
            {
              "name": "maker",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "nft_ca",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "token_id",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "daily_rent",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "max_rental_duration",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "min_collateral",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "list_endtime",
              "type": "uint256",
              "internalType": "uint256"
            }
          ]
        },
        {
          "name": "makerSignature",
          "type": "bytes",
          "internalType": "bytes"
        }
      ],
      "outputs": [],
      "stateMutability": "payable"
    },
    {
      "type": "function",
      "name": "cancelOrder",
      "inputs": [
        {
          "name": "order",
          "type": "tuple",
          "internalType": "struct RenftMarket.RentoutOrder",
          "components": [
            {
              "name": "maker",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "nft_ca",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "token_id",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "daily_rent",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "max_rental_duration",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "min_collateral",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "list_endtime",
              "type": "uint256",
              "internalType": "uint256"
            }
          ]
        },
        {
          "name": "makerSignature",
          "type": "bytes",
          "internalType": "bytes"
        }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
    },
    {
      "type": "function",
      "name": "canceledOrders",
      "inputs": [
        {
          "name": "",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "outputs": [
        {
          "name": "",
          "type": "bool",
          "internalType": "bool"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "eip712Domain",
      "inputs": [],
      "outputs": [
        {
          "name": "fields",
          "type": "bytes1",
          "internalType": "bytes1"
        },
        {
          "name": "name",
          "type": "string",
          "internalType": "string"
        },
        {
          "name": "version",
          "type": "string",
          "internalType": "string"
        },
        {
          "name": "chainId",
          "type": "uint256",
          "internalType": "uint256"
        },
        {
          "name": "verifyingContract",
          "type": "address",
          "internalType": "address"
        },
        {
          "name": "salt",
          "type": "bytes32",
          "internalType": "bytes32"
        },
        {
          "name": "extensions",
          "type": "uint256[]",
          "internalType": "uint256[]"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "orderHash",
      "inputs": [
        {
          "name": "order",
          "type": "tuple",
          "internalType": "struct RenftMarket.RentoutOrder",
          "components": [
            {
              "name": "maker",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "nft_ca",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "token_id",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "daily_rent",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "max_rental_duration",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "min_collateral",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "list_endtime",
              "type": "uint256",
              "internalType": "uint256"
            }
          ]
        }
      ],
      "outputs": [
        {
          "name": "",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "orders",
      "inputs": [
        {
          "name": "",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "outputs": [
        {
          "name": "taker",
          "type": "address",
          "internalType": "address"
        },
        {
          "name": "collateral",
          "type": "uint256",
          "internalType": "uint256"
        },
        {
          "name": "start_time",
          "type": "uint256",
          "internalType": "uint256"
        },
        {
          "name": "rentinfo",
          "type": "tuple",
          "internalType": "struct RenftMarket.RentoutOrder",
          "components": [
            {
              "name": "maker",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "nft_ca",
              "type": "address",
              "internalType": "address"
            },
            {
              "name": "token_id",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "daily_rent",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "max_rental_duration",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "min_collateral",
              "type": "uint256",
              "internalType": "uint256"
            },
            {
              "name": "list_endtime",
              "type": "uint256",
              "internalType": "uint256"
            }
          ]
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "event",
      "name": "BorrowNFT",
      "inputs": [
        {
          "name": "taker",
          "type": "address",
          "indexed": true,
          "internalType": "address"
        },
        {
          "name": "maker",
          "type": "address",
          "indexed": true,
          "internalType": "address"
        },
        {
          "name": "orderHash",
          "type": "bytes32",
          "indexed": false,
          "internalType": "bytes32"
        },
        {
          "name": "collateral",
          "type": "uint256",
          "indexed": false,
          "internalType": "uint256"
        }
      ],
      "anonymous": false
    },
    {
      "type": "event",
      "name": "EIP712DomainChanged",
      "inputs": [],
      "anonymous": false
    },
    {
      "type": "event",
      "name": "OrderCanceled",
      "inputs": [
        {
          "name": "maker",
          "type": "address",
          "indexed": true,
          "internalType": "address"
        },
        {
          "name": "orderHash",
          "type": "bytes32",
          "indexed": false,
          "internalType": "bytes32"
        }
      ],
      "anonymous": false
    },
    {
      "type": "event",
      "name": "OrderHash",
      "inputs": [
        {
          "name": "orderHashValue",
          "type": "bytes32",
          "indexed": false,
          "internalType": "bytes32"
        }
      ],
      "anonymous": false
    },
    {
      "type": "error",
      "name": "ECDSAInvalidSignature",
      "inputs": []
    },
    {
      "type": "error",
      "name": "ECDSAInvalidSignatureLength",
      "inputs": [
        {
          "name": "length",
          "type": "uint256",
          "internalType": "uint256"
        }
      ]
    },
    {
      "type": "error",
      "name": "ECDSAInvalidSignatureS",
      "inputs": [
        {
          "name": "s",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ]
    },
    {
      "type": "error",
      "name": "InvalidShortString",
      "inputs": []
    },
    {
      "type": "error",
      "name": "StringTooLong",
      "inputs": [
        {
          "name": "str",
          "type": "string",
          "internalType": "string"
        }
      ]
    }
  ];

// ERC721 ABI
export const ERC721ABI = [{"inputs":[{"internalType":"string","name":"name_","type":"string"},{"internalType":"string","name":"symbol_","type":"string"},{"internalType":"string","name":"baseURI_","type":"string"},{"internalType":"uint256","name":"maxSupply_","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"ERC721EnumerableForbiddenBatchMint","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"address","name":"owner","type":"address"}],"name":"ERC721IncorrectOwner","type":"error"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ERC721InsufficientApproval","type":"error"},{"inputs":[{"internalType":"address","name":"approver","type":"address"}],"name":"ERC721InvalidApprover","type":"error"},{"inputs":[{"internalType":"address","name":"operator","type":"address"}],"name":"ERC721InvalidOperator","type":"error"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"ERC721InvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"}],"name":"ERC721InvalidReceiver","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"ERC721InvalidSender","type":"error"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ERC721NonexistentToken","type":"error"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"index","type":"uint256"}],"name":"ERC721OutOfBoundsIndex","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"approved","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"operator","type":"address"},{"indexed":false,"internalType":"bool","name":"approved","type":"bool"}],"name":"ApprovalForAll","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[],"name":"MAX_SUPPLY","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"freeMint","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getApproved","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"operator","type":"address"}],"name":"isApprovedForAll","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"bool","name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"index","type":"uint256"}],"name":"tokenByIndex","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"index","type":"uint256"}],"name":"tokenOfOwnerByIndex","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"}];
