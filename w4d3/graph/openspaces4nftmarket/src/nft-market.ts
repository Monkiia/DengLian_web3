import { Bytes } from "@graphprotocol/graph-ts"
import {
  Cancel as CancelEvent,
  List as ListEvent,
  Sold as SoldEvent
} from "../generated/NFTMarket/NFTMarket"
import {
  FilledOrder,
  OrderBook,
} from "../generated/schema"

export function handleCancel(event: CancelEvent): void {
  // get eneity from OrderBook
  let entity = OrderBook.load(event.params.orderId)
  if (entity) {
    entity.cancelTxHash = event.transaction.hash
    entity.save()
  }
}

export function handleList(event: ListEvent): void {
  let entity = new OrderBook(event.params.orderId)
  entity.nft = event.params.nft
  entity.tokenId = event.params.tokenId
  entity.seller = event.params.seller
  entity.payToken = event.params.payToken
  entity.price = event.params.price
  entity.deadline = event.params.deadline
  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash
  // Initlize the cancelTxHash and filledTxHash with Zero given we just list it
  entity.cancelTxHash = Bytes.empty()
  entity.filledTxHash = Bytes.empty()
  entity.save()
}

export function handleSold(event: SoldEvent): void {
  let orderBookEntity = OrderBook.load(event.params.orderId)
  if (orderBookEntity) {
    orderBookEntity.filledTxHash = event.transaction.hash
    orderBookEntity.save()
    let filledOrderEntity = new FilledOrder(event.params.orderId)
    filledOrderEntity.buyer = event.params.buyer
    filledOrderEntity.fee = event.params.fee
    filledOrderEntity.blockNumber = event.block.number
    filledOrderEntity.blockTimestamp = event.block.timestamp
    filledOrderEntity.transactionHash = event.transaction.hash
    filledOrderEntity.order = orderBookEntity.id
    filledOrderEntity.save()
  }
}
