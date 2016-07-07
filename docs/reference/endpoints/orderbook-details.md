---
title: Orderbook Details
clientData:
  laboratoryUrl: https://www.stellar.org/laboratory/#explorer?resource=order_book&endpoint=details
---

People on the Stellar network can make [offers](../resources/offer.md) to buy or sell assets.  These offers are summarized by the assets being bought and sold in [orderbooks](../resources/orderbook.md).

Horizon will return, for each orderbook, a summary of the orderbook and the bids and asks associated with that orderbook.

## Request

```
GET /order_book?selling_asset_type={selling_asset_type}&selling_asset_code={selling_asset_code}&selling_asset_issuer={selling_asset_issuer}&buying_asset_type={buying_asset_type}&buying_asset_code={buying_asset_code}&buying_asset_issuer={buying_asset_issuer}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `selling_asset_type` | required, string | Type of the Asset being sold | `native` |
| `selling_asset_code` | optional, string | Code of the Asset being sold | `USD` |
| `selling_asset_issuer` | optional, string | Account ID of the issuer of the Asset being sold | `GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36` |
| `buying_asset_type` | required, string | Type of the Asset being bought | `credit_alphanum4` |
| `buying_asset_code` | optional, string | Code of the Asset being bought | `BTC` |
| `buying_asset_issuer` | optional, string | Account ID of the issuer of the Asset being bought | `GD6VWBXI6NY3AOOR55RLVQ4MNIDSXE5JSAVXUTF35FRRI72LYPI3WL6Z` |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl "https://horizon-testnet.stellar.org/order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=FOO&buying_asset_issuer=GBAUUA74H4XOQYRSOW2RZUA4QL5PB37U3JS5NE3RTB2ELJVMIF5RLMAG"
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server('https://horizon-testnet.stellar.org');

server.orderbook(new StellarSdk.Asset.native(), new StellarSdk.Asset('FOO', 'GBAUUA74H4XOQYRSOW2RZUA4QL5PB37U3JS5NE3RTB2ELJVMIF5RLMAG'))
  .call()
  .then(function(resp) { console.log(resp); })
  .catch(function(err) { console.log(err); })
```

## Response

The summary of the orderbook and its bids and asks.

## Example Response
```json
{
  "bids": [
    {
      "price_r": {
        "n": 100000000,
        "d": 12953367
      },
      "price": "7.7200005",
      "amount": "12.0000000"
    }
  ],
  "asks": [
    {
      "price_r": {
        "n": 194,
        "d": 25
      },
      "price": "7.7600000",
      "amount": "238.4804125"
    }
  ],
  "base": {
    "asset_type": "native"
  },
  "counter": {
    "asset_type": "credit_alphanum4",
    "asset_code": "FOO",
    "asset_issuer": "GBAUUA74H4XOQYRSOW2RZUA4QL5PB37U3JS5NE3RTB2ELJVMIF5RLMAG"
  }
}
```

## Possible Errors

- The [standard errors](../errors.md#Standard_Errors).
