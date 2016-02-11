---
title: Ledger Details
clientData:
  laboratoryUrl: https://www.stellar.org/laboratory/#explorer?resource=ledgers&endpoint=single
---

The ledger details endpoint provides information on a single [ledger](./resources/ledger.md).

## Request

```
GET /ledgers/{id}
```

### Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `id` | required, number | Ledger ID | `69859` |

### curl Example Request

```sh
curl "https://horizon-testnet.stellar.org/ledgers/69859"
```

### JavaScript Example Request

```js
var StellarSdk = require('./stellar-sdk')
var server = new StellarSdk.Server('https://horizon-testnet.stellar.org');

server.ledgers()
  .ledger('69858')
  .call()
  .then(function(ledgerResult) {
    console.log(ledgerResult)
  })
  .catch(function(err) {
    console.log(err)
  })

```
## Response

This endpoint responds with a single Ledger.  See [ledger resource](./resources/ledger.md) for reference.

### Example Response

```json
{
  "_links": {
    "effects": {
      "href": "/ledgers/69859/effects/{?cursor,limit,order}",
      "templated": true
    },
    "operations": {
      "href": "/ledgers/69859/operations/{?cursor,limit,order}",
      "templated": true
    },
    "self": {
      "href": "/ledgers/69859"
    },
    "transactions": {
      "href": "/ledgers/69859/transactions/{?cursor,limit,order}",
      "templated": true
    }
  },
  "id": "4db1e4f145e9ee75162040d26284795e0697e2e84084624e7c6c723ebbf80118",
  "paging_token": "300042120331264",
  "hash": "4db1e4f145e9ee75162040d26284795e0697e2e84084624e7c6c723ebbf80118",
  "prev_hash": "4b0b8bace3b2438b2404776ce57643966855487ba6384724a3c664c7aa4cd9e4",
  "sequence": 69859,
  "transaction_count": 0,
  "operation_count": 0,
  "closed_at": "2015-07-20T15:51:52Z"
}
```

## Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if there is no ledger whose ID matches the `id` argument.
