import { createPublicClient, http, parseAbiItem, decodeEventLog, Log } from 'viem'
import { mainnet } from 'viem/chains'
import { ethers } from 'ethers'

// Create an Ethereum mainnet client using Infura or Alchemy RPC URL
const client = createPublicClient({
  chain: mainnet,
  transport: http('https://eth-mainnet.g.alchemy.com/v2/_T8UEPlogJ0JFhcO5JtjuHPAJCjQfm1v'),
})

// USDC contract address on Ethereum mainnet
const USDC_CONTRACT_ADDRESS = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'

// ABI for the Transfer event in the ERC20 standard (used by USDC)
const transferEventAbi = parseAbiItem(
  'event Transfer(address indexed from, address indexed to, uint256 value)'
)

async function getRecentUsdcTransfers() {
  // Fetch the current block number (latest block on the chain)
  const latestBlock = await client.getBlockNumber()

  // Set the block range to search within the last 100 blocks
  const startBlock = latestBlock - BigInt(100)

  console.log(`Searching block range: from ${startBlock} to ${latestBlock}`)

  // Fetch logs for the Transfer event from the USDC contract within the block range
  const logs: Log[] = await client.getLogs({
    address: USDC_CONTRACT_ADDRESS, // USDC contract address
    event: transferEventAbi,        // The Transfer event ABI
    fromBlock: startBlock,          // Start block for the search
    toBlock: latestBlock,           // End block for the search
  })

  // Loop through the logs and display the details of each Transfer event
  logs.forEach(log => {
    // Decode the log data
    const decodedLog = decodeEventLog({ abi: [transferEventAbi], data: log.data, topics: log.topics })
    const { from, to, value } = decodedLog.args as { from: string; to: string; value: bigint }
    const actualValue = Number(value) / 1e6;

    // Get the transaction hash of the log (each Transfer event is part of a transaction)
    const transactionHash = log.transactionHash

    // Display the transfer details: from address, to address, value (formatted as USDC), and the transaction hash
    console.log(`USDC Transfer: from ${from} to ${to} value ${actualValue} USDC, txHash: ${transactionHash}`)
  })
}

// Execute the function and catch any errors that might occur
getRecentUsdcTransfers().catch((err) => {
  console.error('Error querying USDC transfers:', err)
})
