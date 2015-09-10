---
id: transactions_for_account
title: Transactions for account
category: Endpoints
---

This endpoint represents all [transactions][resource_transaction] submitted by an [accounts][resources_account].

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

This endpoint responds with a list of transactions for a given account. See [transaction resource][] for reference.

### Example Response

_Endpoint not implemented_

## Streaming

This endpoint can be also streaming data using [Server Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events).

Use [stellar-sdk](https://github.com/stellar/stellar-sdk/) to stream transactions.

## Problems

- The [standard problems][].
- [not_found][problems/not_found]: A `not_found` problem will be returned if there are no transactions in the account whose address matches the `address` argument.

[transaction resource]: ./resource/transaction.md
[problems/not_found]: ../problem/not_found.md
[resources_account]: ./resources/account.md
[resources_transaction]: ./resources/transaction.md
[standard problems]: ../guide/problems.md#Standard_Problems
