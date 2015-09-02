---
id: operations_for_transaction
title: Operations for transaction
category: Endpoints
---

This endpoint represents all [operations][resources_operation] that are part of a given [transaction][resource_transaction].

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
curl https://horizon-testnet.stellar.org/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/operations
```

### JavaScript Example Request

```js
var StellarLib = require('js-stellar-lib');
var server = new StellarLib.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.transactions('3c8ef808df9d5d240ba0d495629df9da5653b1be2daf05d43b49c5bcbfe099bd', 'operations')
  .then(function (operationsResult) {
    console.log(operationsResult.records);
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a list of operations that are part of a given transaction. See [operation resource][] for reference.

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
        "type": 0,
        "type_s": "create_account"
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

## Problems

- The [standard problems][].
- [not_found][problems/not_found]: A `not_found` problem will be returned if there is no transaction hash matches the `hash` argument.

[operation resource]: ./resource/operation.md
[resources_operation]: ./resources/operation.md
[problems/not_found]: ../problem/not_found.md
[resources_transaction]: ./resources/transaction.md
[standard problems]: ../guide/problems.md#Standard_Problems
