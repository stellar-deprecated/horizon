---
title: Trade
---

A trade occurs when offers are completely or partially fulfilled.  For example, let's say that there exists an offer to sell 9 `foo_bank/EUR` for 3 `baz_exchange/BTC` and you make an offer to buy 3 `foo_bank/EUR` for 1 `baz_exchange/BTC`.  Since your offer and the existing one cross, a trade happens.  After the trade completes,

- you are 3 `foo_bank/EUR` richer and 1 `baz_exchange/BTC` poorer
- the maker of the other offer is 1 `baz_exchange/BTC` richer and 3 `foo_bank/EUR` poorer
- your offer is completely fulfilled and no longer exists
- the other offer is partially fulfilled and becomes an offer to sell 6 `foo_bank/EUR` for 2 `baz_exchange/BTC`.  The price of that offer doesn't change, but the amount does.

Trades can also be caused by successful [path payments](https://stellar.org/developers/learn/concepts/exchange.html), because path payments involve fulfilling offers.

Payments are one-way in that afterwards, the source account has a smaller balance and the destination account of the payment has a bigger one.  Trades are two-way; both accounts increase and decrease their balances.

## Attributes
| Attribute    | Type             |                                                                                                                        |
|--------------|------------------|------------------------------------------------------------------------------------------------------------------------|
| ID | string | The ID of this trade. |
| paging_token | string | A [paging token](./page.md) suitable for use as a `cursor` parameter.|
| seller | string | |
| sold_asset_type | string | |
| sold_asset_code | string | |
| sold_asset_issuer | string | |
| buyer | string | |
| bought_asset_type | string | |
| bought_asset_code | string | |
| bought_asset_issuer | string | |

## Links

| rel          | Example                                                                                           | Description                                                | `templated` |
|--------------|---------------------------------------------------------------------------------------------------|------------------------------------------------------------|-------------|
| seller      | `/accounts/{seller}?cursor,limit,order}`      | Link to details about the account that made this offer. | true        |
| buyer | `/accounts/{buyer}?cursor,limit,order}`      | Link to details about the account that took this offer. | true        |
| order_book | `/order_book/{order_book_params} | Link to orderbook of the assets bought and sold. | true |

## Endpoints

| Resource                 | Type       | Resource URI Template                |
|--------------------------|------------|--------------------------------------|
| [Trades for Orderbook](../trades_for_orderbook.md)       | Collection | `/orderbook/trades?{orderbook_params}`       |
