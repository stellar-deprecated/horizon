---
id: ledger
title: Ledger
category: Resources
---

A **ledger** resource contains information about a given ledger. 

To learn more about the concept of ledgers in the Stellar network, take a look at the [Stellar ledger concept guide][concept_ledger].

## Attributes
| Attribute         | Type   |                                                                                                                             |
|-------------------|--------|-----------------------------------------------------------------------------------------------------------------------------|
| id                | string | The id is a unique identifier for this ledger.                                                                               |
| paging_token      | string | A [paging token][] suitable for use as the cursor parameter to ledger resources.                                  |
| hash              | string | A hex-encoded SHA-256 hash of the ledger's [XDR][]-encoded form.                                                                |
| prev_hash         | string | The hash of the ledger that chronologically came before this one.                                                            |
| sequence          | number | Sequence number of this ledger, suitable for use as the as the :id parameter for url templates that require a ledger number. |
| transaction_count | number | The number of transactions in this ledger.                                                                                   |
| operation_count   | number | The number of operations in this ledger.                                                                                     |
| closed_at         | string | An [ISO 8601][] formatted string of when this ledger was closed.                                                             |

## Links
|              | Example                                           | Relation                        | templated |
|--------------|---------------------------------------------------|---------------------------------|-----------|
| self         | `/ledgers/500`                                    |                                 |           |
| effects      | `/ledgers/500/effects/{?cursor,limit,order}`      | The effects in this transaction | true      |
| operations   | `/ledgers/500/operations/{?cursor,limit,order}`   | The operations in this ledger   | true      |
| transactions | `/ledgers/500/transactions/{?cursor,limit,order}` | The transactions in this ledger | true      |


## Example

```json
{
  "_links": {
    "effects": {
      "href": "/ledgers/500/effects/{?cursor,limit,order}",
      "templated": true
    },
    "operations": {
      "href": "/ledgers/500/operations/{?cursor,limit,order}",
      "templated": true
    },
    "self": {
      "href": "/ledgers/500"
    },
    "transactions": {
      "href": "/ledgers/500/transactions/{?cursor,limit,order}",
      "templated": true
    }
  },
  "id": "689f00d4824b8e69330bf4ad7eb10092ff2f8fdb76d4668a41eebb9469ef7f30",
  "paging_token": "2147483648000",
  "hash": "689f00d4824b8e69330bf4ad7eb10092ff2f8fdb76d4668a41eebb9469ef7f30",
  "prev_hash": "b608e110c7cc58200c912140f121af50dc5ef407aabd53b76e1741080aca1cf0",
  "sequence": 500,
  "transaction_count": 0,
  "operation_count": 0,
  "closed_at": "2015-07-09T21:39:28Z"
}
```

## Endpoints
| Resource                | Type       | Resource URI Template              |
|-------------------------|------------|------------------------------------|
| [All ledgers][]         | Collection | `/ledgers`                         |
| [Single Ledger][]       | Single     | `/ledgers/:id`                     |
| [Ledger Transactions][] | Collection | `/ledgers/:ledger_id/transactions` |
| [Ledger Operations][]   | Collection | `/ledgers/:ledger_id/operations`   |
| [Ledger Payments][]     | Collection | `/ledgers/:ledger_id/payments`     |
| [Ledger Effects][]      | Collection | `/ledgers/:ledger_id/effects`      |

[All ledgers]: ../endpoint/ledgers_all.md
[Single Ledger]: ../endpoint/ledgers_single.md
[Ledger Transactions]: ../endpoint/ledger_transactions.md
[Ledger Operations]: ../endpoint/ledgers_operations.md
[Ledger Payments]: ../endpoint/ledgers_payments.md
[Ledger Effects]: ../endpoint/ledgers_effects.md
[ISO 8601]: https://en.wikipedia.org/wiki/ISO_8601
[paging token]: ./page.md
[concept_ledger]: https://github.com/stellar/docs/tree/master/docs/ledger.md
