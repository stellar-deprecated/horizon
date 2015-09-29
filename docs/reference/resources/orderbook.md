---
title: Orderbook
---

[Orderbooks](https://stellar.org/developers/learn/concepts/exchange.html) are collections of offers for each issuer and currency pairs.  Let's say you wanted to exchange EUR issued by a particular bank for BTC issued by a particular exchange.  You would look at the orderbook and see who is buying `foo_bank/EUR` and selling `baz_exchange/BTC` and at what prices.

## Attributes
| Attribute    | Type             |                                                                                                                        |
|--------------|------------------|------------------------------------------------------------------------------------------------------------------------|
| bids | object     |  Array of {`price_r`, `price`, `amount`} objects (see [offers](./offer.md)).  These represent prices and amounts accounts are willing to buy for the given `selling` and `buying` pair. |
| asks | object |  Array of {`price_r`, `price`, `amount`} objects (see [offers](./offer.md)).  These represent prices and amounts accounts are willing to sell for the given `selling` and `buying` pair.|
| selling | [Asset](http://stellar.org/developers/learn/concepts/assets.html) | The Asset this offer wants to sell.|
| buying | [Asset](http://stellar.org/developers/learn/concepts/assets.html) | The Asset this offer wants to buy.|

## Links

This resource has no links.


## Endpoints

| Resource                 | Type       | Resource URI Template                |
|--------------------------|------------|--------------------------------------|
| [Orderbook Details](../orderbook_details.md)       | Single | `/orderbook?{orderbook_params}`       |
| [Trades for Orderbook](../trades_for_orderbook.md)       | Collection | `/orderbook/trades?{orderbook_params}`       |



