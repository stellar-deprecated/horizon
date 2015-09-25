---
id: payments_all
title: All Payments
category: Endpoints
---

This endpoint represents all payment [operations](./resources/operation.md) that are part of validated [transactions](./resources/transaction.md). This endpoint can also be used in [streaming](../learn/responses.md#streaming) mode so it is possible to use it to listen for new payments as they get made in the Stellar network.

## Request

```
GET /payments{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```bash
# Retrieve the first 200 payments, ordered chronologically.
curl https://horizon-testnet.stellar.org/payments?limit=200
```

```bash
# Retrieve a page of payments to occur immediately before the transaction
# specified by the paging token "1234".
curl https://horizon-testnet.stellar.org/payments?cursor=1234&order=desc
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.payments()
  .call()
  .then(function (paymentResults) {
    console.log(paymentResults.records)
  })
  .catch(function (err) {
    console.log(err)
  })
```
## Response

This endpoint responds with a list of payments. See [operation resource](./resources/operation.md) for more information about operations (and payment operations).

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
      "href": "?order=asc&limit=2&cursor=463856472064"
    },
    "prev": {
      "href": "?order=desc&limit=2&cursor=77309415424"
    },
    "self": {
      "href": "?order=asc&limit=2&cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
