---
title: Transaction Details
---

The transaction details endpoint provides information on a single [transaction](./resources/transaction.md). The transaction hash provided in the `hash` argument specifies which transaction to load.

## Request

```
GET /transactions/{hash}
```

### Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `hash` | required, string | A transaction hash, hex-encoded. | 6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a |

### curl Example Request

```sh
curl "https://horizon-testnet.stellar.org/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a"
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.transactions()
  .transaction("3c8ef808df9d5d240ba0d495629df9da5653b1be2daf05d43b49c5bcbfe099bd")
  .call()
  .then(function (transactionResult) {
    console.log(transactionResult)
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

This endpoint responds with a single Transaction.  See [transaction resource](./resources/transaction.md) for reference.

### Example Response

```json
{
  "_links": {
    "account": {
      "href": "/accounts/GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K"
    },
    "effects": {
      "href": "/transactions/fa78cb43d72171fdb2c6376be12d57daa787b1fa1a9fdd0e9453e1f41ee5f15a/effects{?cursor,limit,order}",
      "templated": true
    },
    "ledger": {
      "href": "/ledgers/146970"
    },
    "operations": {
      "href": "/transactions/fa78cb43d72171fdb2c6376be12d57daa787b1fa1a9fdd0e9453e1f41ee5f15a/operations{?cursor,limit,order}",
      "templated": true
    },
    "precedes": {
      "href": "/transactions?cursor=631231343497216\u0026order=asc"
    },
    "self": {
      "href": "/transactions/fa78cb43d72171fdb2c6376be12d57daa787b1fa1a9fdd0e9453e1f41ee5f15a"
    },
    "succeeds": {
      "href": "/transactions?cursor=631231343497216\u0026order=desc"
    }
  },
  "id": "fa78cb43d72171fdb2c6376be12d57daa787b1fa1a9fdd0e9453e1f41ee5f15a",
  "paging_token": "631231343497216",
  "hash": "fa78cb43d72171fdb2c6376be12d57daa787b1fa1a9fdd0e9453e1f41ee5f15a",
  "ledger": 146970,
  "created_at": "2015-09-24T10:07:09Z",
  "account": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
  "account_sequence": 279172874343,
  "max_fee": 0,
  "fee_paid": 0,
  "operation_count": 1,
  "result_code": 0,
  "result_code_s": "tx_success",
  "envelope_xdr": "AAAAAGXNhLrhGtltTwCpmqlarh7s1DB2hIkbP//jgzn4Fos/AAAACgAAAEEAAABnAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA2ddmTOFAgr21Crs2RXRGLhiAKxicZb/IERyEZL/Y2kUAAAAXSHboAAAAAAAAAAAB+BaLPwAAAECDEEZmzbgBr5fc3mfJsCjWPDtL6H8/vf16me121CC09ONyWJZnw0PUvp4qusmRwC6ZKfLDdk8F3Rq41s+yOgQD",
  "result_xdr": "AAAAAAAAAAoAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=",
  "result_meta_xdr": "AAAAAAAAAAEAAAACAAAAAAACPhoAAAAAAAAAANnXZkzhQIK9tQq7NkV0Ri4YgCsYnGW/yBEchGS/2NpFAAAAF0h26AAAAj4aAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQACPhoAAAAAAAAAAGXNhLrhGtltTwCpmqlarh7s1DB2hIkbP//jgzn4Fos/AABT8kS2c/oAAABBAAAAZwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA"
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there is no account whose ID matches the `address` argument.
