---
title: Trades for Orderbook
---

People on the Stellar network can make [offers](./resources/offer.md) to buy or sell assets.  These offers are summarized by the assets being bought and sold in [orderbooks](./resources/orderbook.md).  When an offer is fully or partially fulfilled, a [trade](./resources/trade.md) happens.

Horizon will return a list of trades by the orderbook the trade's assets are associated with.

## Request

```
GET /order_book/trades?selling_asset_type={selling_asset_type}&selling_asset_code={selling_asset_code}&selling_asset_issuer={selling_asset_issuer}&buying_asset_type={buying_asset_type}&buying_asset_code={buying_asset_code}&buying_asset_issuer={buying_asset_issuer}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `selling_asset_type` | required, string | Type of the Asset being sold | `native` |
| `selling_asset_code` | optional, string | Code of the Asset being sold | `USD` |
| `selling_asset_issuer` | optional, string | Address of the issuer of the Asset being sold | 'GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36' |
| `buying_asset_type` | required, string | Type of the Asset being bought | `credit_alphanum4` |
| `buying_asset_code` | optional, string | Code of the Asset being bought | `BTC` |
| `buying_asset_issuer` | optional, string | Address of the issuer of the Asset being bought | 'GD6VWBXI6NY3AOOR55RLVQ4MNIDSXE5JSAVXUTF35FRRI72LYPI3WL6Z' |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl "https://horizon-testnet.stellar.org/order_book/trades?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=USD&buying_asset_issuer=GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.orderbook(new StellarSdk.Asset("EUR", "GCQPYGH4K57XBDENKKX55KDTWOTK5WDWRQOH2LHEDX3EKVIQRLMESGBG"), new StellarSdk.Asset("USD", "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"))
  .trades()
  .call()
  .then(function(resp) { console.log(resp); })
  .catch(function(err) { console.log(err); })
```

## Response

The list of trades.

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
