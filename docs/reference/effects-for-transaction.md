---
id: effects_for_transaction
title: Effects for transaction
category: Endpoints
---

This endpoint represents all [effects](./resources/effect.md) that occurred as a result of a given [transaction](./resources/transaction.md).

## Request

```
GET /transactions/{hash}/effects{?cursor,limit,order}
```

## Arguments

| name     | notes                          | description                                                      | example                                                           |
| ------   | -------                        | -----------                                                      | -------                                                           |
| `hash`   | required, string               | A transaction hash, hex-encoded                                  | `6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a`|
| `?cursor`| optional, default _null_       | A paging token, specifying where to start returning records from.| `12884905984`                                                     |
| `?order` | optional, string, default `asc`| The order in which to return rows, "asc" or "desc".              | `asc`                                                             |
| `?limit` | optional, number, default `10` | Maximum number of records to return.                             | `200`                                                             |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/effects
```

### JavaScript Example Request

```javascript
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.effects()
  .forTransaction("2ca4cb42fda85f4f0b4bc0a0dc6517a7f109761d0da784cb7c38fb6ee378b1b5")
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

This endpoint responds with a list of effects on the ledger as a result of a given transaction. See [effect resource](./resources/effect.md) for reference.

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
        "type": 0,
        "type_s": "account_created"
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
        "type": 3,
        "type_s": "account_debited"
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
        "type": 10,
        "type_s": "signer_created",
        "weight": 2
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/transactions/2a2beb163e2c68bd2377aab243d68225626d70263444a85556ec7271d4e46e03/effects?order=asc\u0026limit=10\u0026cursor=141733924865-3"
    },
    "prev": {
      "href": "/transactions/2a2beb163e2c68bd2377aab243d68225626d70263444a85556ec7271d4e46e03/effects?order=desc\u0026limit=10\u0026cursor=141733924865-1"
    },
    "self": {
      "href": "/transactions/2a2beb163e2c68bd2377aab243d68225626d70263444a85556ec7271d4e46e03/effects?order=asc\u0026limit=10\u0026cursor="
    }
  }
}
```

## Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not_found.md): A `not_found` error will be returned if there are no effects for transaction whose hash matches the `hash` argument.
