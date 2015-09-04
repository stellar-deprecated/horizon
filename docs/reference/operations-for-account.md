---
id: operations_for_account
title: Operations for account
category: Endpoints
---

This endpoint represents all [operations][resources_operation] that occurred in the [ledger][resources_ledger] as a result of [transactions][resource_transaction] submitted by the [accounts][resources_account].

## Request

```
GET /accounts/{account}/operations{?cursor,limit,order}
```

### Arguments

| name     | notes                          | description                                                      | example                                                   |
| ------   | -------                        | -----------                                                      | -------                                                   |
| `account`| required, string               | Account address                                                  | `GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36`|
| `?cursor`| optional, default _null_       | A paging token, specifying where to start returning records from.| `12884905984`                                             |
| `?order` | optional, string, default `asc`| The order in which to return rows, "asc" or "desc".              | `asc`                                                     |
| `?limit` | optional, number, default `10` | Maximum number of records to return.                             | `200`                                                     |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/operations
```

### JavaScript Example Request

```js
var StellarLib = require('js-stellar-sdk');
var server = new StellarLib.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.accounts('GAKLBGHNHFQ3BMUYG5KU4BEWO6EYQHZHAXEWC33W34PH2RBHZDSQBD75', 'operations')
  .then(function (operationsResult) {
    console.log(operationsResult.records)
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a list of operations that occurred in the ledger as a result of transactions submitted by the account. See [operation resource][] for reference.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "effects": {
            "href": "/operations/46316927324160/effects/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/operations?cursor=46316927324160&order=asc"
          },
          "self": {
            "href": "/operations/46316927324160"
          },
          "succeeds": {
            "href": "/operations?cursor=46316927324160&order=desc"
          },
          "transactions": {
            "href": "/transactions/46316927324160"
          }
        },
        "account": "GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB",
        "funder": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "id": 46316927324160,
        "paging_token": "46316927324160",
        "starting_balance": 1e+09,
        "type": 0,
        "type_s": "create_account"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/accounts/GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB/operations?order=asc&limit=10&cursor=46316927324160"
    },
    "prev": {
      "href": "/accounts/GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB/operations?order=desc&limit=10&cursor=46316927324160"
    },
    "self": {
      "href": "/accounts/GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB/operations?order=asc&limit=10&cursor="
    }
  }
}
```

## Streaming

This endpoint can be also streaming data using [Server Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events).

Use [js-stellar-sdk](https://github.com/stellar/js-stellar-sdk/) to stream operations.

## Problems

- The [standard problems][].
- [not_found][problems/not_found]: A `not_found` problem will be returned if the account whose address matches the `address` does not exist.

[operation resource]: ./resource/operation.md
[resources_operation]: ./resources/operation.md
[problems/not_found]: ../problem/not_found.md
[resources_account]: ./resources/account.md
[resources_ledger]: ./resources/ledger.md
[resources_transaction]: ./resources/transaction.md
[standard problems]: ../guide/problems.md#Standard_Problems
