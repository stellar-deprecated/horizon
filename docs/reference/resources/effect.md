---
id: effect
title: Effect
category: Resources
---

A successful operation will yield zero or more **effects**.  These effects
represent specific changes that occur in the ledger, but are not necessarily
directly reflected in the [ledger][concept_ledger] or [history][concept_history], as [transactions][concept_transactions] and [operations][concept_operations] are.

## Effect types

We can distinguish 4 effect groups:
- Account effects
- Signer effects
- Trustline effects
- Trading effects

### Account effects

| Type                        | Operation                                             |
| --- | --- |
| Account Created             | create_account                                        |
| Account Removed             | merge_account                                         |
| Account Credited            | create_account, payment, path_payment, merge_account  |
| Account Debited             | create_account, payment, path_payment, create_account |
| Account Thresholds Updated  | set_options                                           |
| Account Home Domain Updated | set_options                                           |
| Account Flags Updated       | set_options                                           |

### Signer effects

| Type           | Operation   |
| --- | --- |
| Signer Created | set_options |
| Signer Removed | set_options |
| Signer Updated | set_options |

### Trustline effects

| Type                   | Operation                 |
| --- | --- |
| Trustline Created      | change_trust              |
| Trustline Removed      | change_trust              |
| Trustline Updated      | change_trust, allow_trust |
| Trustline Authorized   | allow_trust               |
| Trustline Deauthorized | allow_trust               |

### Trading effects

| Type          | Operation                                        |
| --- | --- |
| Offer Created | manage_offer, create_passive_offer               |
| Offer Removed | manage_offer, create_passive_offer, path_payment |
| Offer Updated | manage_offer, create_passive_offer, path_payment |
| Trade         | manage_offer, create_passive_offer, path_payment |


## Attributes

Attributes depend on effect type.

## Links

| rel | Example | Relation |
| --- | ------- | -------- |
| self    | `/effects?order=asc\u0026limit=1` |          |
| prev    | `/effects?order=desc\u0026limit=1\u0026cursor=141733924865-1` |          |
| next    | `/effects?order=asc\u0026limit=1\u0026cursor=141733924865-1` |          |
| operation    | `/operations/141733924865` | Operation that created the effect |

## Example

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
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/effects?order=asc\u0026limit=1\u0026cursor=141733924865-1"
    },
    "prev": {
      "href": "/effects?order=desc\u0026limit=1\u0026cursor=141733924865-1"
    },
    "self": {
      "href": "/effects?order=asc\u0026limit=1\u0026cursor="
    }
  }
}
```

## Endpoints

|  Resource                |    Type    |    Resource URI Template             |
| ------------------------ | ---------- | ------------------------------------ |
| [All Effect][]           | Collection | `/effects`                           |
| [Operation Effects][]    | Collection | `/operations/:id/effects`            |
| [Account Effects][]      | Collection | `/accounts/:account_id/effects`      |
| [Ledger Effects][]       | Collection | `/ledgers/:ledger_id/effects`        |

[concept_ledger][https://github.com/stellar/docs/tree/master/docs/ledger.md]
[concept_history][https://github.com/stellar/docs/tree/master/docs/history.md]
[concept_transactions]: https://github.com/stellar/docs/tree/master/docs/transaction.md
[concept_operations]: https://github.com/stellar/docs/tree/master/docs/operations.md
