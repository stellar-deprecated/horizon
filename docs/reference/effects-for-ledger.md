---
id: effects_for_ledger
title: Effects for ledger
category: Endpoints
---

Effects are the ways that the ledger was changed by any transaction.

This endpoint represents all [effects][resources_effects] that occurred in the given [ledger][resources_ledger].

## Request

```
GET /ledgers/{id}/effects{?cursor,limit,order}
```

## Arguments

| name     | notes                          | description                                                      | example      |
| ------   | -------                        | -----------                                                      | -------      |
| `id`     | required, number               | Ledger ID                                                        | `69859`      |
| `?cursor`| optional, default _null_       | A paging token, specifying where to start returning records from.| `12884905984`|
| `?order` | optional, string, default `asc`| The order in which to return rows, "asc" or "desc".              | `asc`        |
| `?limit` | optional, number, default `10` | Maximum number of records to return.                             | `200`        |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/ledgers/69859/effects
```

## Response

This endpoint responds with a list of effects that occurred in the ledger. See [effect resource][] for reference.

### Example Response

Endpoint not implemented yet.

## Errors

- The [standard errors][].
- [not_found][errors/not_found]: A `not_found` error will be returned if there are no effects for a given ledger.

[effect resource]: ./resource/effect.md
[errors/not_found]: ../error/not_found.md
[resources_effects]: ./resources/effect.md
[resources_ledger]: ./resources/ledger.md
[standard errors]: ../guide/errors.md#Standard_Errors
