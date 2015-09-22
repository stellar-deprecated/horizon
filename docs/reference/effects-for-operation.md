---
id: effects_for_operation
title: Effects for operation
category: Endpoints
---

This endpoint represents all [effects](./resources/effect.md) that occurred as a result of a given [operation](./resources/operation.md).

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

This endpoint responds with a list of effects on the ledger as a result of a given operation. See [effect resource](./resources/effect.md) for reference.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "operation": {
            "href": "/operations/141733924865"
          },
          "precedes": {
            "href": "/effects?cursor=141733924865-1\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=141733924865-1\u0026order=desc"
          }
        },
        "account": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
        "paging_token": "141733924865-1",
        "starting_balance": "10000000.0",
        "type": 0,
        "type_s": "account_created"
      },
      {
        "_links": {
          "operation": {
            "href": "/operations/141733924865"
          },
          "precedes": {
            "href": "/effects?cursor=141733924865-2\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=141733924865-2\u0026order=desc"
          }
        },
        "account": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
        "amount": "10000000.0",
        "asset_type": "native",
        "paging_token": "141733924865-2",
        "type": 3,
        "type_s": "account_debited"
      },
      {
        "_links": {
          "operation": {
            "href": "/operations/141733924865"
          },
          "precedes": {
            "href": "/effects?cursor=141733924865-3\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=141733924865-3\u0026order=desc"
          }
        },
        "account": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
        "paging_token": "141733924865-3",
        "public_key": "GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
        "type": 10,
        "type_s": "signer_created",
        "weight": 2
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/operations/141733924865/effects?order=asc\u0026limit=10\u0026cursor=141733924865-3"
    },
    "prev": {
      "href": "/operations/141733924865/effects?order=desc\u0026limit=10\u0026cursor=141733924865-1"
    },
    "self": {
      "href": "/operations/141733924865/effects?order=asc\u0026limit=10\u0026cursor="
    }
  }
}
```

## Possible Errors

- The [standard errors](../guide/errors.md#Standard_Errors).
- [not_found](./errors/not_found.md): A `not_found` errors will be returned if there are no effects for operation whose ID matches the `id` argument.

