---
id: transactions_for_account
title: Transactions for account
category: Endpoints
---

This endpoint represents all [transactions](./resources/transaction.md) submitted by an [accounts](./resources/account.md).
This endpoint can also be used in [streaming](../guide/responses.md#streaming) mode so it is possible to use it to listen for new transactions from a given account as they get made in the Stellar network.

## Request

```
GET /accounts/{address}/transactions{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `address` | required, string | Address of an account | GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | 12884905984 |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/transactions
```

## Response

This endpoint responds with a list of transactions for a given account. See [transaction resource](./resources/transaction.md) for reference.

### Example Response

_Endpoint not implemented_



## Possible Errors

- The [standard errors](../guide/errors.md#Standard_Errors).
- [not_found](./errors/not_found.md): A `not_found` error will be returned if there is no account whose ID matches the `address` argument.
