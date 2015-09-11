---
id: transactions_single
title: Transaction Details
category: Endpoints
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
curl https://horizon-testnet.stellar.org/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.transactions('3c8ef808df9d5d240ba0d495629df9da5653b1be2daf05d43b49c5bcbfe099bd')
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
      "href": "/accounts/GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO"
    },
    "effects": {
      "href": "/transactions/29084c8f70ceed1ae2d0721e73fa1856002c286cde4ae8d5fa9ca2c9d12bebc5/effects/{?cursor,limit,order}",
      "templated": true
    },
    "ledger": {
      "href": "/ledgers/68042"
    },
    "operations": {
      "href": "/transactions/29084c8f70ceed1ae2d0721e73fa1856002c286cde4ae8d5fa9ca2c9d12bebc5/operations/{?cursor,limit,order}",
      "templated": true
    },
    "precedes": {
      "href": "/transactions?cursor=292238164758528&order=asc"
    },
    "self": {
      "href": "/transactions/29084c8f70ceed1ae2d0721e73fa1856002c286cde4ae8d5fa9ca2c9d12bebc5"
    },
    "succeeds": {
      "href": "/transactions?cursor=292238164758528&order=desc"
    }
  },
  "id": "29084c8f70ceed1ae2d0721e73fa1856002c286cde4ae8d5fa9ca2c9d12bebc5",
  "paging_token": "292238164758528",
  "hash": "29084c8f70ceed1ae2d0721e73fa1856002c286cde4ae8d5fa9ca2c9d12bebc5",
  "ledger": 68042,
  "account": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
  "account_sequence": 77309411360,
  "max_fee": 10,
  "fee_paid": 10,
  "operation_count": 1,
  "result_code": 0,
  "result_code_s": "tx_success",
  "envelope_xdr": "TODO",
  "result_xdr": "TODO",
  "result_meta_xdr": "TODO"
}
```

## Possible Errors

- The [standard errors](../guide/errors.md#Standard_Errors).
- [not_found](./errors/not_found.md): A `not_found` error will be returned if there is no account whose ID matches the `address` argument.
