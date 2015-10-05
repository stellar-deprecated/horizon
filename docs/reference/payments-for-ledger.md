---
title: Payments for Ledger
---

This endpoint represents all payment [operations](./resources/operation.md) that are part of a valid [transactions](./resources/transaction.md) in a given [ledger](./resources/ledger.md).

## Request

```
GET /ledgers/{id}/payments{?cursor,limit,order}
```

### Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `id` | required, number | Ledger ID | `69859` |
| `?cursor` | optional, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/ledgers/69859/payments
```

### JavaScript Example Request

```js
var StellarSdk = require('./stellar-sdk')
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.payments()
  .forLedger("10866")
  .call()
  .then(function (paymentResult) {
    console.log(paymentResult)
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a list of payment operations in a given ledger.  See [operation resource](./resources/operation.md) for more information about operations (and payment operations).

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "effects": {
            "href": "/operations/77309415424/effects/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/operations?cursor=77309415424&order=asc"
          },
          "self": {
            "href": "/operations/77309415424"
          },
          "succeeds": {
            "href": "/operations?cursor=77309415424&order=desc"
          },
          "transactions": {
            "href": "/transactions/77309415424"
          }
        },
        "account": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "funder": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ",
        "id": 77309415424,
        "paging_token": "77309415424",
        "starting_balance": 1e+14,
        "type": 0,
        "type_s": "create_account"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "?order=asc&limit=10&cursor=77309415424"
    },
    "prev": {
      "href": "?order=desc&limit=10&cursor=77309415424"
    },
    "self": {
      "href": "?order=asc&limit=10&cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there is no account whose ID matches the `address` argument.
