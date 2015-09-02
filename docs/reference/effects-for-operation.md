---
id: effects_for_operation
title: Effects for operation
category: Endpoints
---

This endpoint represents all [effects][resources_effects] that occurred in the [ledger][resources_ledger] as a result of a given [operation][resources_operation].

## Request

```
GET /operations/{id}/effects{?cursor,limit,order}
```

### Arguments

| name     | notes                          | description                                                      | example      |
| ------   | -------                        | -----------                                                      | -------      |
| `id`     | required, number               | An operation ID                                                  | `77309415424`|
| `?cursor`| optional, default _null_       | A paging token, specifying where to start returning records from.| `12884905984`|
| `?order` | optional, string, default `asc`| The order in which to return rows, "asc" or "desc".              | `asc`        |
| `?limit` | optional, number, default `10` | Maximum number of records to return.                             | `200`        |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/operations/77309415424/effects
```

## Response

This endpoint responds with a list of effects that occurred in the ledger as a result of a given operation. See [effect resource][] for reference.

### Example Response

Endpoint not implemented yet.

## Errors

- The [standard errors][].
- [not_found][errors/not_found]: A `not_found` errors will be returned if there are no effects for operation whose ID matches the `id` argument.

[effect resource]: ./resource/effect.md
[problems/not_found]: ../problem/not_found.md
[resources_effects]: ./resources/effect.md
[resources_ledger]: ./resources/ledger.md
[resources_operation]: ./resources/operation.md
[standard errors]: ../guide/errors.md#Standard_Errors
