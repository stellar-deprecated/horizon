---
id: operations_for_ledger
title: Operations for ledger
category: Endpoints
---

This endpoint returns all [operations](./resources/operation.md) that occurred in a given [ledger](./resources/ledger.md).

## Request

```
GET /ledgers/{id}/operations{?cursor,limit,order}
```

### Arguments

| name     | notes                          | description                                                      | example      |
| ------   | -------                        | -----------                                                      | -------      |
| `id`     | required, number               | Ledger ID                                                        | `69859`      |
| `?cursor`| optional, default _null_       | A paging token, specifying where to start returning records from.| `12884905984`|
| `?order` | optional, string, default `asc`| The order in which to return rows, "asc" or "desc".              | `asc`        |
| `?limit` | optional, number, default `10` | Maximum number of records to return.                             | `200`        |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/ledgers/69859/operations
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.operations()
  .forLedger("10866")
  .call()
  .then(function (operationsResult) {
    console.log(operationsResult.records);
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a list of operations in a given ledger.  See [operation resource](./resources/operation.md) for reference.

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
      "href": "/ledgers/18/operations?order=asc&limit=10&cursor=77309415424"
    },
    "prev": {
      "href": "/ledgers/18/operations?order=desc&limit=10&cursor=77309415424"
    },
    "self": {
      "href": "/ledgers/18/operations?order=asc&limit=10&cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not_found.md): A `not_found` error will be returned if there is no account whose ID matches the `address` argument.
