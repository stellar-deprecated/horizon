---
id: effects_for_transaction
title: Effects for transaction
category: Endpoints
---

This endpoint represents all [effects][resources_effects] that occurred in the [ledger][resources_ledger] as a result of a given [transaction][resource_transaction].

## Request

```
GET /transactions/{hash}/effects{?cursor,limit,order}
```

## Arguments

| name     | notes                          | description                                                      | example                                                           |
| ------   | -------                        | -----------                                                      | -------                                                           |
| `hash`   | required, string               | A transaction hash, hex-encoded                                  | `6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a`|
| `?cursor`| optional, default _null_       | A paging token, specifying where to start returning records from.| `12884905984`                                                     |
| `?order` | optional, string, default `asc`| The order in which to return rows, "asc" or "desc".              | `asc`                                                             |
| `?limit` | optional, number, default `10` | Maximum number of records to return.                             | `200`                                                             |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/effects
```

## Response

This endpoint responds with a list of effects that occurred in the ledger as a result of a given transaction. See [effect resource][] for reference.

### Example Response

Endpoint not implemented yet.

## Errors

- The [standard errors][].
- [not_found][errors/not_found]: A `not_found` error will be returned if there are no effects for transaction whose hash matches the `hash` argument.

[effect resource]: ./resource/effect.md
[transaction]: ./resource/transaction.md
[errors/not_found]: ../error/not_found.md
[resources_effects]: ./resources/effect.md
[resources_ledger]: ./resources/ledger.md
[resources_transaction]: ./resources/transaction.md
[standard errors]: ../guide/errors.md#Standard_Errors
