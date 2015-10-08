---
title: Effects for Account
---

This endpoint represents all [effects](./resources/effect.md) that changed a given [account](./resources/account.md). It will return relevant effects from the creation of the account to the current ledger.

This endpoint can also be used in [streaming](../learn/responses.md#streaming) mode so it is possible to use it to listen for new effects as transactions happen in the Stellar network.
If called in streaming mode Horizon will start at the earliest known effect unless a `cursor` is set. In that case it will start from the `cursor`. You can also set `cursor` value to `now` to only stream effects created since your request time.

## Request

```
GET /accounts/{account}/effects{?cursor,limit,order}
```

## Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `account` | required, string | Account address | `GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36` |
| `?cursor` | optional, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc".               | `asc`         |
| `?limit`  | optional, number, default `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/effects
```

### JavaScript Example Request

```javascript
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.effects()
  .forAccount("GD6VWBXI6NY3AOOR55RLVQ4MNIDSXE5JSAVXUTF35FRRI72LYPI3WL6Z")
  .call()
  .then(function (effectResults) {
    //page 1
    console.log(effectResults.records)
  })
  .catch(function (err) {
    console.log(err)
  })

```

## Response

The list of effects.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "operation": {
            "href": "/operations/214748368897"
          },
          "precedes": {
            "href": "/effects?cursor=214748368897-1\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=214748368897-1\u0026order=desc"
          }
        },
        "account": "GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK",
        "paging_token": "214748368897-1",
        "starting_balance": "100.0",
        "type_i": 0,
        "type": "account_created"
      },
      {
        "_links": {
          "operation": {
            "href": "/operations/214748368897"
          },
          "precedes": {
            "href": "/effects?cursor=214748368897-3\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=214748368897-3\u0026order=desc"
          }
        },
        "account": "GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK",
        "paging_token": "214748368897-3",
        "public_key": "GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK",
        "type_i": 10,
        "type": "signer_created",
        "weight": 2
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/accounts/GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK/effects?order=asc\u0026limit=10\u0026cursor=214748368897-3"
    },
    "prev": {
      "href": "/accounts/GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK/effects?order=desc\u0026limit=10\u0026cursor=214748368897-1"
    },
    "self": {
      "href": "/accounts/GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK/effects?order=asc\u0026limit=10\u0026cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there are no effects for the given account.

