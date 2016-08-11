---
title: Ledger
---

A **ledger** resource contains information about a given ledger.

To learn more about the concept of ledgers in the Stellar network, take a look at the [Stellar ledger concept guide](https://www.stellar.org/developers/learn/concepts/ledger.html).

## Attributes
| Attribute         | Type   |                                                                                                                               |
|-------------------|--------|-------------------------------------------------------------------------------------------------------------------------------|
| id                | string | The id is a unique identifier for this ledger.                                                                                |
| paging_token      | number | A [paging token](./page.md) suitable for use as a `cursor` parameter.                                                         |
| hash              | string | A hex-encoded SHA-256 hash of the ledger's [XDR](../../learn/xdr.md)-encoded form.                                            |
| prev_hash         | string | The hash of the ledger that chronologically came before this one.                                                             |
| sequence          | number | Sequence number of this ledger, suitable for use as the as the :id parameter for url templates that require a ledger number.  |
| transaction_count | number | The number of transactions in this ledger.                                                                                    |
| operation_count   | number | The number of operations in this ledger.                                                                                      |
| closed_at         | string | An [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) formatted string of when this ledger was closed.                        |
| total_coins       | string | The total number of lumens in circulation *(in stroops)*.                                                                     |
| fee_pool          | string | The sum of all transaction fees *(in stroops)* since the last inflation operation. They are redistributed during [inflation]. |
| base_fee          | number | The [fee] the network charges per operation in a transaction.                                                                 |
| base_reserve      | string | The [reserve][fee] the network uses when calculating an account's minimum balance.                                            |
| max_tx_set_size   | number | The maximum number of transactions validators have agreed to process in a given ledger.                                       |

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
| [All ledgers](../ledgers-all.md)         | Collection | `/ledgers`                         |
| [Single Ledger](../ledgers-single.md)       | Single     | `/ledgers/:id`                     |
| [Ledger Transactions](../transactions-for-ledger.md) | Collection | `/ledgers/:ledger_id/transactions` |
| [Ledger Operations](../operations-for-ledger.md)   | Collection | `/ledgers/:ledger_id/operations`   |
| [Ledger Payments](../payments-for-ledger.md)     | Collection | `/ledgers/:ledger_id/payments`     |
| [Ledger Effects](../effects-for-ledger.md)      | Collection | `/ledgers/:ledger_id/effects`      |



[inflation]: https://www.stellar.org/developers/learn/concepts/inflation.html
[fee]: https://www.stellar.org/developers/learn/concepts/fees.html
