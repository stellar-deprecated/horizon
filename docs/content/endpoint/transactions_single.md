---
id: transactions_single
title: Transaction Details
category: Endpoints
---

The transaction details endpoint provides information on a single transaction
within the ledger. The transaction hash provided in the `hash` argument specifies
which transaction to load


## Request

```
GET /transactions/{hash}
```

### Arguments

|  name  |  type  |           description           |                             example                              |
| ------ | ------ | ------------------------------- | ---------------------------------------------------------------- |
| `hash` | string | A transaction hash, hex-encoded | 6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a |

### Example

```
curl https://horizon-testnet.stellar.org/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a
```

## Response

This endpoint responds with a single Transaction.  See [transaction resource][transaction] for reference.

### Example

TODO

### Problems

- The [standard errors][se].
- [not_found][problems/not_found]: A `not_found` problem will be returned if there is no transaction in the ledger whose hash matches the `hash` argument.

[transaction]: {{< relref "resource/transaction.md" >}}
[problems/not_found]: {{< relref "problem/not_found.md" >}}
[se]: {{< relref "guide/problems.md" >}}#standard_errors
