---
id: effects_for_account
title: Effects for account
category: Endpoints
---

This endpoint represents all [effects][resources_effects] that changed a given [account][resources_account]. It will return relevant effects from the creation of the account to the current ledger.

## Request

```
GET /accounts/{account}/effects{?cursor,limit,order}
```

## Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `account` | required, string | Account address | `GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36` |
| `?cursor` | optional, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc".               | `asc`         |
| `?limit`  | optional, number, default `10` | Maximum number of records to return. | `200` |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/effects
```

## Response

The list of effects.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "_links": {
          "operation": {
            "href": "/operations/214748368897"
          },
          "precedes": {
            "href": "/effects?cursor=214748368897-1\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=214748368897-1\u0026order=desc"
          }
        },
        "account": "GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK",
        "paging_token": "214748368897-1",
        "starting_balance": "100.0",
        "type": 0,
        "type_s": "account_created"
      },
      {
        "_links": {
          "operation": {
            "href": "/operations/214748368897"
          },
          "precedes": {
            "href": "/effects?cursor=214748368897-3\u0026order=asc"
          },
          "succeeds": {
            "href": "/effects?cursor=214748368897-3\u0026order=desc"
          }
        },
        "account": "GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK",
        "paging_token": "214748368897-3",
        "public_key": "GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK",
        "type": 10,
        "type_s": "signer_created",
        "weight": 2
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/accounts/GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK/effects?order=asc\u0026limit=10\u0026cursor=214748368897-3"
    },
    "prev": {
      "href": "/accounts/GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK/effects?order=desc\u0026limit=10\u0026cursor=214748368897-1"
    },
    "self": {
      "href": "/accounts/GC6NFQDTVH2YMVZSXJIVLCRHLFAOVOT32JMDFZJZ34QFSSVT7M5G2XFK/effects?order=asc\u0026limit=10\u0026cursor="
    }
  }
}
```

## Errors

- The [standard errors][].
- [not_found][errors/not_found]: A `not_found` error will be returned if there are no effects for the given account.

[effect resource]: ./resource/effect.md
[transaction]: ./resource/transaction.md
[errors/not_found]: ../errors/not_found.md
[resources_account]: ./resources/account.md
[resources_effects]: ./resources/effect.md
[resources_ledger]: ./resources/ledger.md
[resources_transaction]: ./resources/transaction.md
[standard errors]: ../guide/errors.md#Standard_Errors
