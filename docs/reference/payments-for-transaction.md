---
title: Payments for transaction
---

This endpoint represents all payment [operations](./resources/operation.md) that are part of a given [transaction](./resources/transaction.md).

## Request

```
GET /transactions/{hash}/payments{?cursor,limit,order}
```

### Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `hash` | required, string | A transaction hash, hex-encoded | `6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a` |
| `?cursor` | optional, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc".               | `asc`         |
| `?limit`  | optional, number, default `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/transactions/3c8ef808df9d5d240ba0d495629df9da5653b1be2daf05d43b49c5bcbfe099bd/payments
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.payments()
  .forTransaction("3c8ef808df9d5d240ba0d495629df9da5653b1be2daf05d43b49c5bcbfe099bd")
  .call()
  .then(function (paymentResult) {
    console.log(paymentResult.records);
  })
  .catch(function (err) {
    console.log(err);
  })
```
## Response

This endpoint responds with a list of payments operations that are part of a given transaction. See [operation resource](./resources/operation.md) for more information about operations (and payment operations).

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "effects": {
            "href": "/operations/46428596473856/effects/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/operations?cursor=46428596473856&order=asc"
          },
          "self": {
            "href": "/operations/46428596473856"
          },
          "succeeds": {
            "href": "/operations?cursor=46428596473856&order=desc"
          },
          "transactions": {
            "href": "/transactions/46428596473856"
          }
        },
        "account": "GAKLBGHNHFQ3BMUYG5KU4BEWO6EYQHZHAXEWC33W34PH2RBHZDSQBD75",
        "funder": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "id": 46428596473856,
        "paging_token": "46428596473856",
        "starting_balance": 1e+09,
        "type": 0,
        "type_s": "create_account"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "?order=asc&limit=10&cursor=46428596473856"
    },
    "prev": {
      "href": "?order=desc&limit=10&cursor=46428596473856"
    },
    "self": {
      "href": "?order=asc&limit=10&cursor="
    }
  }
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there is no account whose ID matches the `address` argument.
