import { Transfer } from "../generated/NFT/NFT";
import { TokenInfo } from "../generated/schema";
import { BigInt } from "@graphprotocol/graph-ts";

export function handleTransfer(event: Transfer): void {
  // Generate a unique ID by combining contract address and token ID
  let tokenId = event.params.tokenId.toString();
  let contractAddress = event.address.toHex();
  let id = contractAddress + "-" + tokenId;

  // Load or create a new TokenInfo entity
  let token = TokenInfo.load(id);
  if (!token) {
    token = new TokenInfo(id);
    token.tokenId = event.params.tokenId;
    token.ca = event.address;
    token.tokenURL = ""; // You may populate this field if you have metadata URLs
    token.name = ""; // Set this if you can retrieve the NFT's name
  }

  // Update fields based on the Transfer event
  token.owner = event.params.to;
  token.blockTimestamp = event.block.timestamp;
  
  // Save the entity
  token.save();
}
