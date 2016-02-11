---
title: Operations for Transaction
clientData:
  laboratoryUrl: https://www.stellar.org/laboratory/#explorer?resource=operations&endpoint=for_transaction
---

This endpoint represents all [operations](./resources/operation.md) that are part of a given [transaction](./resources/transaction.md).

## Request

```
GET /transactions/{hash}/operations{?cursor,limit,order}
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
curl "https://horizon-testnet.stellar.org/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/operations"
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server('https://horizon-testnet.stellar.org');

server.operations()
  .forTransaction("3c8ef808df9d5d240ba0d495629df9da5653b1be2daf05d43b49c5bcbfe099bd")
  .call()
  .then(function (operationsResult) {
    console.log(operationsResult.records);
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a list of operations that are part of a given transaction. See [operation resource](./resources/operation.md) for reference.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "effects": {
            "href": "/operations/352573865332736/effects/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/operations?cursor=352573865332736&order=asc"
          },
          "self": {
            "href": "/operations/352573865332736"
          },
          "succeeds": {
            "href": "/operations?cursor=352573865332736&order=desc"
          },
          "transactions": {
            "href": "/transactions/352573865332736"
          }
        },
        "account": "GBU3FDYZK5VTU7A3SIGC443E5OV6MXUI5DXOI22SPT3OPK7AGIIWOZLF",
        "funder": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "id": 352573865332736,
        "paging_token": "352573865332736",
        "starting_balance": 1e+09,
        "type_i": 0,
        "type": "create_account"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/transactions/e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149/operations?order=asc&limit=10&cursor=352573865332736"
    },
    "prev": {
      "href": "/transactions/e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149/operations?order=desc&limit=10&cursor=352573865332736"
    },
    "self": {
      "href": "/transactions/e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149/operations?order=asc&limit=10&cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there is no account whose ID matches the `hash` argument.
