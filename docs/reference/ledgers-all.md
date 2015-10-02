---
title: All Ledgers
---

This endpoint represents all [ledgers](./resources/ledger.md).
This endpoint can also be used in [streaming](../learn/responses.md#streaming) mode so it is possible to use it to get notifications as ledgers are closed by the Stellar network.

## Request

```
GET /ledgers{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
# Retrieve the 200 latest ledgers, ordered chronologically
curl https://horizon-testnet.stellar.org/ledgers?limit=200&order=desc
```

### JavaScript Example Request

```js
server.ledgers()
  .call()
  .then(function (ledgerResult) {
    // page 1
    console.log(ledgerResult.records)
    return ledgerResult.next()
  })
  .then(function (ledgerResult) {
    // page 2
    console.log(ledgerResult.records)
  })
  .catch(function(err) {
    console.log(err)
  })
```
## Response

This endpoint responds with a list of ledgers.  See [ledger resource](./resources/ledger.md) for reference.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "effects": {
            "href": "/ledgers/1/effects/{?cursor,limit,order}",
            "templated": true
          },
          "operations": {
            "href": "/ledgers/1/operations/{?cursor,limit,order}",
            "templated": true
          },
          "self": {
            "href": "/ledgers/1"
          },
          "transactions": {
            "href": "/ledgers/1/transactions/{?cursor,limit,order}",
            "templated": true
          }
        },
        "id": "e8e10918f9c000c73119abe54cf089f59f9015cc93c49ccf00b5e8b9afb6e6b1",
        "paging_token": "4294967296",
        "hash": "e8e10918f9c000c73119abe54cf089f59f9015cc93c49ccf00b5e8b9afb6e6b1",
        "sequence": 1,
        "transaction_count": 0,
        "operation_count": 0,
        "closed_at": "1970-01-01T00:00:00Z"
      },
      {
        "_links": {
          "effects": {
            "href": "/ledgers/2/effects/{?cursor,limit,order}",
            "templated": true
          },
          "operations": {
            "href": "/ledgers/2/operations/{?cursor,limit,order}",
            "templated": true
          },
          "self": {
            "href": "/ledgers/2"
          },
          "transactions": {
            "href": "/ledgers/2/transactions/{?cursor,limit,order}",
            "templated": true
          }
        },
        "id": "e12e5809ab8c59d8256e691cb48a024dd43960bc15902d9661cd627962b2bc71",
        "paging_token": "8589934592",
        "hash": "e12e5809ab8c59d8256e691cb48a024dd43960bc15902d9661cd627962b2bc71",
        "prev_hash": "e8e10918f9c000c73119abe54cf089f59f9015cc93c49ccf00b5e8b9afb6e6b1",
        "sequence": 2,
        "transaction_count": 0,
        "operation_count": 0,
        "closed_at": "2015-07-16T23:49:00Z"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/ledgers?order=asc&limit=2&cursor=8589934592"
    },
    "prev": {
      "href": "/ledgers?order=desc&limit=2&cursor=4294967296"
    },
    "self": {
      "href": "/ledgers?order=asc&limit=2&cursor="
    }
  }
}
```

## Errors

- The [standard errors](../learn/errors.md#Standard_Errors).



