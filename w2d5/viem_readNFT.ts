const { createPublicClient, http } = require("viem");
const { mainnet } = require("viem/chains");

const client = createPublicClient({
  chain: mainnet,
  transport: http(
    "https://eth-mainnet.g.alchemy.com/v2/_T8UEPlogJ0JFhcO5JtjuHPAJCjQfm1v",
  ),
});

// Replace with the correct NFT contract address (your provided address)
const nftAddress = "0x0483b0dfc6c78062b9e999a82ffb795925381415";

// ERC-721 ABI for tokenURI function
const tokenURI_nftABI = [
  {
    constant: true,
    inputs: [
      {
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "tokenURI",
    outputs: [
      {
        name: "",
        type: "string",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
];

const ownerOf_nftABI = [
  {
    constant: true,
    inputs: [
      {
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "ownerOf",
    outputs: [
      {
        name: "",
        type: "address",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
];

// Convert IPFS URI to HTTP
function convertIpfsToHttp(ipfsUri) {
  if (ipfsUri.startsWith("ipfs://")) {
    return ipfsUri.replace("ipfs://", "https://ipfs.io/ipfs/");
  }
  return ipfsUri; // Return as is if it's already HTTP
}

// Convert IPFS URI to HTTP
function convertIpfsToHttp(ipfsUri) {
  if (ipfsUri.startsWith("ipfs://")) {
    return ipfsUri.replace("ipfs://", "https://ipfs.io/ipfs/");
  }
  return ipfsUri; // Return as is if it's already HTTP
}

// Fetch the tokenURI for a specific NFT token
async function getNFTMetadata(tokenId) {
  try {
    console.log(
      `Fetching tokenURI for token ID ${tokenId} from contract ${nftAddress}`,
    );

    const tokenURI = await client.readContract({
      address: nftAddress,
      abi: tokenURI_nftABI,
      functionName: "tokenURI",
      args: [tokenId],
    });

    console.log(`Token URI for token ${tokenId}: ${tokenURI}`);

    // Convert IPFS URI to HTTP if necessary
    const httpURI = convertIpfsToHttp(tokenURI);

    // Fetch the metadata from the HTTP URI
    const metadataResponse = await fetch(httpURI);
    const metadata = await metadataResponse.json();

    console.log("NFT Metadata:", metadata);
  } catch (error) {
    console.error("Error fetching NFT data:", error);
  }
}

// Fetch the owner of the NFT token
async function getNFTOwner(tokenId) {
  try {
    console.log(
      `Fetching owner for token ID ${tokenId} from contract ${nftAddress}`,
    );

    const ownerAddress = await client.readContract({
      address: nftAddress,
      abi: ownerOf_nftABI,
      functionName: "ownerOf",
      args: [tokenId],
    });

    console.log(`Owner of token ${tokenId}: ${ownerAddress}`);
    return ownerAddress;
  } catch (error) {
    console.error("Error fetching NFT owner:", error);
  }
}

// Example: Fetch metadata for token ID 1
getNFTMetadata(1);
// Example: Fetch owner for token ID 1
getNFTOwner(1);

/**
 * Result
 * Fetching tokenURI for token ID 1 from contract 0x0483b0dfc6c78062b9e999a82ffb795925381415
Token URI for token 1: ipfs://QmY9wa5FssaBBhLyyC2r649rwfS7CcvH7NG5AJWepeDkGj/1.json
NFT Metadata: {
  dna: 'b5940ead98dd50c06ccdb56ccfa37123ff083ca3',
  name: 'ORBIT#1 Metaverse 1 Time and Space',
  description: '',
  image: 'ipfs://QmT3wMgcmm9R1dC1F63rBFdQdGYCfWfpv1D1PXYXTwrEaQ/1.jpg',
  edition: 1,
  date: 1715078282818,
  attributes: [
    { trait_type: 'Category', value: 'Metaverse' },
    { trait_type: 'Color', value: 'Green' },
    { trait_type: 'Planet', value: 'Moderate' },
    { trait_type: 'Years', value: '2018' },
    { trait_type: 'Characters', value: 'Null' },
    { trait_type: 'Shapes', value: 'Square' },
    { trait_type: 'Elements', value: 'Mixed' }
  ]
}

Owner of token 1: 0x6897625C2Da7E985e9c22E0d7B27A960Fc81D1D2
 */
