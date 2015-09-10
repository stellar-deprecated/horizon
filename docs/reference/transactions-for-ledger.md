---
id: transactions_for_ledger
title: Transactions for ledger
category: Endpoints
---

This endpoint represents all [transactions][resource_transaction] in a given [ledger][resources_ledger].

## Request

```
GET /ledgers/{id}/transactions{?cursor,limit,order}
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
curl https://horizon-testnet.stellar.org/ledgers/69859/transactions
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.ledgers('8365', 'transactions')
  .then(function (accountResults) {
    console.log(accountResults.records)
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a list of transactions in a given ledger.  See [transaction resource][] for reference.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "account": {
            "href": "/accounts/GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO"
          },
          "effects": {
            "href": "/transactions/6082107f0b5f018bbcd901f142e4f297cbd6b494158baf3a5e69e7e35dc654a3/effects/{?cursor,limit,order}",
            "templated": true
          },
          "ledger": {
            "href": "/ledgers/69018"
          },
          "operations": {
            "href": "/transactions/6082107f0b5f018bbcd901f142e4f297cbd6b494158baf3a5e69e7e35dc654a3/operations/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/transactions?cursor=296430052839424&order=asc"
          },
          "self": {
            "href": "/transactions/6082107f0b5f018bbcd901f142e4f297cbd6b494158baf3a5e69e7e35dc654a3"
          },
          "succeeds": {
            "href": "/transactions?cursor=296430052839424&order=desc"
          }
        },
        "id": "6082107f0b5f018bbcd901f142e4f297cbd6b494158baf3a5e69e7e35dc654a3",
        "paging_token": "296430052839424",
        "hash": "6082107f0b5f018bbcd901f142e4f297cbd6b494158baf3a5e69e7e35dc654a3",
        "ledger": 69018,
        "account": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "account_sequence": 77309411361,
        "max_fee": 10,
        "fee_paid": 10,
        "operation_count": 1,
        "result_code": 0,
        "result_code_s": "tx_success",
        "envelope_xdr": "TODO",
        "result_xdr": "TODO",
        "result_meta_xdr": "TODO"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/ledgers/69018/transactions?order=asc&limit=10&cursor=296430052839424"
    },
    "prev": {
      "href": "/ledgers/69018/transactions?order=desc&limit=10&cursor=296430052839424"
    },
    "self": {
      "href": "/ledgers/69018/transactions?order=asc&limit=10&cursor="
    }
  }
}
```

## Problems

- The [standard problems][].
- [not_found][problems/not_found]: A `not_found` problem will be returned if there are no transactions in the ledger whose ID matches the `hash` argument.

[transaction resource]: ./resource/transaction.md
[problems/not_found]: ../problem/not_found.md
[resources_ledger]: ./resources/ledger.md
[resources_transaction]: ./resources/transaction.md
[standard problems]: ../guide/problems.md#Standard_Problems
