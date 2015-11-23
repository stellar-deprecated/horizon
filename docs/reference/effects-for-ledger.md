---
title: Effects for Ledger
---

Effects are the specific ways that the ledger was changed by any operation.

This endpoint represents all [effects](./resources/effect.md) that occurred in the given [ledger](./resources/ledger.md).

## Request

```
GET /ledgers/{id}/effects{?cursor,limit,order}
```

## Arguments

| name     | notes                          | description                                                      | example      |
| ------   | -------                        | -----------                                                      | -------      |
| `id`     | required, number               | Ledger ID                                                        | `69859`      |
| `?cursor`| optional, default _null_       | A paging token, specifying where to start returning records from.| `12884905984`|
| `?order` | optional, string, default `asc`| The order in which to return rows, "asc" or "desc".              | `asc`        |
| `?limit` | optional, number, default `10` | Maximum number of records to return.                             | `200`        |

### curl Example Request

```sh
curl "https://horizon-testnet.stellar.org/ledgers/69859/effects"
```

### JavaScript Example Request

```javascript
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.effects()
  .forLedger("2")
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

This endpoint responds with a list of effects that occurred in the ledger. See [effect resource](./resources/effect.md) for reference.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "operation": {
            "href": "/operations/141733924865"
          },
          "precedes": {
            "href": "/effects?cursor=141733924865-1\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=141733924865-1\u0026order=desc"
          }
        },
        "account": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
        "paging_token": "141733924865-1",
        "starting_balance": "10000000.0",
        "type_i": 0,
        "type": "account_created"
      },
      {
        "_links": {
          "operation": {
            "href": "/operations/141733924865"
          },
          "precedes": {
            "href": "/effects?cursor=141733924865-2\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=141733924865-2\u0026order=desc"
          }
        },
        "account": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
        "amount": "10000000.0",
        "asset_type": "native",
        "paging_token": "141733924865-2",
        "type_i": 3,
        "type": "account_debited"
      },
      {
        "_links": {
          "operation": {
            "href": "/operations/141733924865"
          },
          "precedes": {
            "href": "/effects?cursor=141733924865-3\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=141733924865-3\u0026order=desc"
          }
        },
        "account": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
        "paging_token": "141733924865-3",
        "public_key": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
        "type_i": 10,
        "type": "signer_created",
        "weight": 2
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/ledgers/33/effects?order=asc\u0026limit=10\u0026cursor=141733924865-3"
    },
    "prev": {
      "href": "/ledgers/33/effects?order=desc\u0026limit=10\u0026cursor=141733924865-1"
    },
    "self": {
      "href": "/ledgers/33/effects?order=asc\u0026limit=10\u0026cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there are no effects for a given ledger.
