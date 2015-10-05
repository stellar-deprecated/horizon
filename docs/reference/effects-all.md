---
title: All Effects
---

This endpoint represents all [effects](./resources/effect.md).

This endpoint can also be used in [streaming](../learn/responses.md#streaming) mode so it is possible to use it to listen for new effects as transactions happen in the Stellar network.
If called in streaming mode Horizon will start at the earliest known effect unless a `cursor` is set. In that case it will start from the `cursor`. You can also set `cursor` value to `now` to only stream effects created since your request time.

## Request

```
GET /effects{?cursor,limit,order}
```

## Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `?cursor` | optional, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc".               | `asc`         |
| `?limit`  | optional, number, default `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/effects
```

### JavaScript Example Request

```javascript
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.effects()
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
            "href": "/operations/279172878337"
          },
          "precedes": {
            "href": "/effects?cursor=279172878337-1\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=279172878337-1\u0026order=desc"
          }
        },
        "account": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
        "paging_token": "279172878337-1",
        "starting_balance": "10000000.0",
        "type": 0,
        "type_s": "account_created"
      },
      {
        "_links": {
          "operation": {
            "href": "/operations/279172878337"
          },
          "precedes": {
            "href": "/effects?cursor=279172878337-2\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=279172878337-2\u0026order=desc"
          }
        },
        "account": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
        "amount": "10000000.0",
        "asset_type": "native",
        "paging_token": "279172878337-2",
        "type": 3,
        "type_s": "account_debited"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/effects?order=asc\u0026limit=2\u0026cursor=279172878337-2"
    },
    "prev": {
      "href": "/effects?order=desc\u0026limit=2\u0026cursor=279172878337-1"
    },
    "self": {
      "href": "/effects?order=asc\u0026limit=2\u0026cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there are no effects for the given account.

