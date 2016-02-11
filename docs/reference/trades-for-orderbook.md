---
title: Trades for Orderbook
clientData:
  laboratoryUrl: https://www.stellar.org/laboratory/#explorer?resource=order_book&endpoint=trades
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
| `selling_asset_issuer` | optional, string | Account ID of the issuer of the Asset being sold | 'GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36' |
| `buying_asset_type` | required, string | Type of the Asset being bought | `credit_alphanum4` |
| `buying_asset_code` | optional, string | Code of the Asset being bought | `BTC` |
| `buying_asset_issuer` | optional, string | Account ID of the issuer of the Asset being bought | 'GD6VWBXI6NY3AOOR55RLVQ4MNIDSXE5JSAVXUTF35FRRI72LYPI3WL6Z' |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl "https://horizon-testnet.stellar.org/order_book/trades?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=FOO&buying_asset_issuer=GBAUUA74H4XOQYRSOW2RZUA4QL5PB37U3JS5NE3RTB2ELJVMIF5RLMAG"
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.orderbook(new StellarSdk.Asset.native(), new StellarSdk.Asset('FOO', 'GBAUUA74H4XOQYRSOW2RZUA4QL5PB37U3JS5NE3RTB2ELJVMIF5RLMAG'))
  .trades()
  .call()
  .then(function(resp) { console.log(resp); })
  .catch(function(err) { console.log(err); })
```

## Response

The list of trades.

### Example Response
```js
{
  "_links": {
    "self": {
      "href": "https://horizon-testnet.stellar.org/order_book/trades?order=asc\u0026limit=10\u0026cursor="
    },
    "next": {
      "href": "https://horizon-testnet.stellar.org/order_book/trades?order=asc\u0026limit=10\u0026cursor=7281919481876481-2"
    },
    "prev": {
      "href": "https://horizon-testnet.stellar.org/order_book/trades?order=desc\u0026limit=10\u0026cursor=7281893712072705-2"
    }
  },
  "_embedded": {
    "records": [
      {
        "_links": {
          "self": {
            "href": "https://horizon-testnet.stellar.org/accounts/GCJ34JYMXNI7N55YREWAACMMZECOMTPIYDTFCQBWPUP7BLJQDDTVGUW4"
          },
          "seller": {
            "href": "https://horizon-testnet.stellar.org/accounts/GCJ34JYMXNI7N55YREWAACMMZECOMTPIYDTFCQBWPUP7BLJQDDTVGUW4"
          },
          "buyer": {
            "href": "https://horizon-testnet.stellar.org/accounts/GD42RQNXTRIW6YR3E2HXV5T2AI27LBRHOERV2JIYNFMXOBA234SWLQQB"
          }
        },
        "id": "7281893712072705-2",
        "paging_token": "7281893712072705-2",
        "seller": "GCJ34JYMXNI7N55YREWAACMMZECOMTPIYDTFCQBWPUP7BLJQDDTVGUW4",
        "sold_asset_type": "native",
        "buyer": "GD42RQNXTRIW6YR3E2HXV5T2AI27LBRHOERV2JIYNFMXOBA234SWLQQB",
        "bought_asset_type": "credit_alphanum4",
        "bought_asset_code": "FOO",
        "bought_asset_issuer": "GBAUUA74H4XOQYRSOW2RZUA4QL5PB37U3JS5NE3RTB2ELJVMIF5RLMAG"
      },
      {
        "_links": {
          "self": {
            "href": "https://horizon-testnet.stellar.org/accounts/GCJ34JYMXNI7N55YREWAACMMZECOMTPIYDTFCQBWPUP7BLJQDDTVGUW4"
          },
          "seller": {
            "href": "https://horizon-testnet.stellar.org/accounts/GCJ34JYMXNI7N55YREWAACMMZECOMTPIYDTFCQBWPUP7BLJQDDTVGUW4"
          },
          "buyer": {
            "href": "https://horizon-testnet.stellar.org/accounts/GD42RQNXTRIW6YR3E2HXV5T2AI27LBRHOERV2JIYNFMXOBA234SWLQQB"
          }
        },
        "id": "7281919481876481-2",
        "paging_token": "7281919481876481-2",
        "seller": "GCJ34JYMXNI7N55YREWAACMMZECOMTPIYDTFCQBWPUP7BLJQDDTVGUW4",
        "sold_asset_type": "native",
        "buyer": "GD42RQNXTRIW6YR3E2HXV5T2AI27LBRHOERV2JIYNFMXOBA234SWLQQB",
        "bought_asset_type": "credit_alphanum4",
        "bought_asset_code": "FOO",
        "bought_asset_issuer": "GBAUUA74H4XOQYRSOW2RZUA4QL5PB37U3JS5NE3RTB2ELJVMIF5RLMAG"
      }
    ]
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
