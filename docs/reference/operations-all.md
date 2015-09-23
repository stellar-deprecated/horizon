---
id: operations_all
title: All Operations
category: Endpoints
---

This endpoint represents all [operations](./resources/operation.md) that are part of validated [transactions](./resources/transaction.md).
This endpoint can also be used in [streaming](../guide/responses.md#streaming) mode so it is possible to use it to listen as operations are processed in the Stellar network.

## Request

```
GET /operations{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/operations?limit=200&order=desc
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.operations()
  .call()
  .then(function (operationsResult) {
    //page 1
    console.log(operationsResult.records)
    return operationsResult.next()
  })
  .then(function (operationsResult) {
    //page 2
    console.log(operationsResult.records)
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a list of operations. See [operation resource](./resources/operation.md) for reference.

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
      },
      {
        "_links": {
          "effects": {
            "href": "/operations/463856472064/effects/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/operations?cursor=463856472064&order=asc"
          },
          "self": {
            "href": "/operations/463856472064"
          },
          "succeeds": {
            "href": "/operations?cursor=463856472064&order=desc"
          },
          "transactions": {
            "href": "/transactions/463856472064"
          }
        },
        "account": "GC2ADYAIPKYQRGGUFYBV2ODJ54PY6VZUPKNCWWNX2C7FCJYKU4ZZNKVL",
        "funder": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "id": 463856472064,
        "paging_token": "463856472064",
        "starting_balance": 1e+09,
        "type": 0,
        "type_s": "create_account"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/operations?order=asc&limit=2&cursor=463856472064"
    },
    "prev": {
      "href": "/operations?order=desc&limit=2&cursor=77309415424"
    },
    "self": {
      "href": "/operations?order=asc&limit=2&cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../guide/errors.md#Standard_Errors).
