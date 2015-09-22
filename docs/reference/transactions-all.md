---
id: transactions_all
title: All Transactions
category: Endpoints
---

This endpoint represents all validated [transactions](./resources/transaction.md).
This endpoint can also be used in [streaming](../guide/responses.md#streaming) mode. This makes it possible to use it to listen for new transactions as they get made in the Stellar network.
If called in streaming mode Horizon will start at the earliest known transaction unless a cursor is set. In that case it will start from the cursor.

## Request

```
GET /transactions{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
# Retrieve the 200 latest transactions, ordered chronologically:
curl https://horizon-testnet.stellar.org/transactions?limit=200&order=desc
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.transactions()
  .then(function (transactionResult) {
    //page 1
    console.log(transactionResult.records);
    return transactionResult.next();
  })
  .then(function (transactionResult) {
    console.log(transactionResult.records);
  })
  .catch(function (err) {
    console.log(err)
  })
```

## Response

If called normally this endpoint responds with a [page](./resources/page.md) of transactions.
If called in streaming mode the transaction resources are returned individually.
See [transaction resource](./resources/transaction.md) for reference.

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
            "href": "/transactions/e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149/effects/{?cursor,limit,order}",
            "templated": true
          },
          "ledger": {
            "href": "/ledgers/82090"
          },
          "operations": {
            "href": "/transactions/e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149/operations/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/transactions?cursor=352573865332736&order=asc"
          },
          "self": {
            "href": "/transactions/e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149"
          },
          "succeeds": {
            "href": "/transactions?cursor=352573865332736&order=desc"
          }
        },
        "id": "e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149",
        "paging_token": "352573865332736",
        "hash": "e648b8f9b00c6a04267b3d204c97d08181a13a9b8f3dce8ba28e96b03114b149",
        "ledger": 82090,
        "account": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "account_sequence": 77309411366,
        "max_fee": 10,
        "fee_paid": 10,
        "operation_count": 1,
        "result_code": 0,
        "result_code_s": "tx_success",
        "envelope_xdr": "TODO",
        "result_xdr": "TODO",
        "result_meta_xdr": "TODO"
      },
      {
        "_links": {
          "account": {
            "href": "/accounts/GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO"
          },
          "effects": {
            "href": "/transactions/90bbf06388a0b3c7f77a7f964d8e24d76e7631a9ed4a03aad37cd99371ce0280/effects/{?cursor,limit,order}",
            "templated": true
          },
          "ledger": {
            "href": "/ledgers/73976"
          },
          "operations": {
            "href": "/transactions/90bbf06388a0b3c7f77a7f964d8e24d76e7631a9ed4a03aad37cd99371ce0280/operations/{?cursor,limit,order}",
            "templated": true
          },
          "precedes": {
            "href": "/transactions?cursor=317724500692992&order=asc"
          },
          "self": {
            "href": "/transactions/90bbf06388a0b3c7f77a7f964d8e24d76e7631a9ed4a03aad37cd99371ce0280"
          },
          "succeeds": {
            "href": "/transactions?cursor=317724500692992&order=desc"
          }
        },
        "id": "90bbf06388a0b3c7f77a7f964d8e24d76e7631a9ed4a03aad37cd99371ce0280",
        "paging_token": "317724500692992",
        "hash": "90bbf06388a0b3c7f77a7f964d8e24d76e7631a9ed4a03aad37cd99371ce0280",
        "ledger": 73976,
        "account": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "account_sequence": 77309411365,
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
      "href": "/transactions?order=desc&limit=2&cursor=317724500692992"
    },
    "prev": {
      "href": "/transactions?order=asc&limit=2&cursor=352573865332736"
    },
    "self": {
      "href": "/transactions?order=desc&limit=2&cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../guide/errors.md#Standard_Errors).
