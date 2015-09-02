---
id: transaction
title: Transaction
category: Resources
---

**Transactions** are the basic unit of change in the Stellar Network.

A transaction is a grouping of [operations][].

To learn more about the concept of transactions in the Stellar network, take a look at the [Stellar transactions concept guide][concept_transactions].

## Attributes

|    Attribute     |  Type  |                                                                                                                                |
| ---------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------ |
| id               | string | The canonical id of this transaction, suitable for use as the :id parameter for url templates that require a transaction's ID. |
| paging_token     | string | A [paging token][page_token] suitable for use as the `cursor` parameter to transaction collection resources.                   |
| hash             | string | A hex-encoded SHA-256 hash of the transaction's [XDR][]-encoded form.                                                              |
| ledger           | number | Sequence number of the ledger in which this transaction was applied. `null` if the transaction is failed or unvalidated.       |
| account          | string |                                                                                                                                |
| account_sequence | number |                                                                                                                                |
| max_fee          | number | The maximum fee willing to be paid by the transaction creator in lumens.                          |
| fee_paid         | number | The fee paid by the source account of this transaction when the transaction was applied to the ledger.                         |
| operation_count  | number | The number of operations that are contained within this transaction.                                                           |
| result_code      | number | The numeric result code for this transaction                                                                                   |
| result_code_s    | string | The string result code for this transaction                                                                                                                              |
| envelope_xdr     | string | A base64 encoded string of the raw `TransactionEnvelope` xdr struct for this transaction                                       |
| result_xdr       | string | A base64 encoded string of the raw `TransactionResultPair` xdr struct for this transaction                                     |
| result_meta_xdr  | string | A base64 encoded string of the raw `TransactionMeta` xdr struct for this transaction                                           |

## Links

|                   rel                    |                                           Example                                           |                             Description                          |
| ---------------------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [self][transactions/single]              | `/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a`            |                                                                  |
| [account][accounts/single]               | `/accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ`                             | The source account for this transaction.                         |
| [ledger][ledgers/single]                 | `/ledgers/3`                                                                                | The ledger in which this transaction was applied.                |
| [operations][operations/for_transaction] | `/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/operations` |                                                                  |
| [effects][effects/for_transaction]       | `/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/effects`    |                                                                  |
| [precedes][transactions/all]             | `/transactions?cursor=12884905984&order=asc`                                                | A collection of transactions that occur after this transaction. |
| [succeeds][transactions/all]             | `/transactions?cursor=12884905984&order=desc`                                               | A collection of transactions that occur before this transaction. |

## Example

```json
{
  "_links": {
    "account": {
      "href": "/accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ"
    },
    "effects": {
      "href": "/transactions/75fe8425d8b19a69689d98b68527c1ef9f83ce068c2c1c9fff5386d62b2af53f/effects/{?cursor,limit,order}",
      "templated": true
    },
    "ledger": {
      "href": "/ledgers/18"
    },
    "operations": {
      "href": "/transactions/75fe8425d8b19a69689d98b68527c1ef9f83ce068c2c1c9fff5386d62b2af53f/operations/{?cursor,limit,order}",
      "templated": true
    },
    "precedes": {
      "href": "/transactions?cursor=77309415424&order=asc"
    },
    "self": {
      "href": "/transactions/75fe8425d8b19a69689d98b68527c1ef9f83ce068c2c1c9fff5386d62b2af53f"
    },
    "succeeds": {
      "href": "/transactions?cursor=77309415424&order=desc"
    }
  },
  "id": "75fe8425d8b19a69689d98b68527c1ef9f83ce068c2c1c9fff5386d62b2af53f",
  "paging_token": "77309415424",
  "hash": "75fe8425d8b19a69689d98b68527c1ef9f83ce068c2c1c9fff5386d62b2af53f",
  "ledger": 18,
  "account": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ",
  "account_sequence": 1,
  "max_fee": 10,
  "fee_paid": 10,
  "operation_count": 1,
  "result_code": 0,
  "result_code_s": "tx_success",
  "envelope_xdr": "TODO",
  "result_xdr": "TODO",
  "result_meta_xdr": "TODO"
}
```

## Endpoints

|  Resource                |    Type    |    Resource URI Template             |
| ------------------------ | ---------- | ------------------------------------ |
| [All Transactions][]     | Collection | `/transactions`                      |
| [Transaction Details][]  | Single     | `/transactions/:id`                  |
| [Account Transactions][] | Collection | `/accounts/:account_id/transactions` |
| [Ledger Transactions][]  | Collection | `/ledgers/:ledger_id/transactions`   |


## Submitting transactions
To submit a new transaction to Stellar network, it must first be built and signed locally. Then you can submit a hex representation of your transaction’s [XDR][] to the `/transactions` endpoint. Read more about submitting transactions in [Post Transaction] doc.


[All Transactions]: ../endpoint/transactions_all.md
[Transaction Details]: ../endpoint/transactions_single.md
[Account Transactions]: ../endpoint/transactions_for_account.md
[Ledger Transactions]: ../endpoint/transactions_for_ledger.md
[XDR]: ../guide/xdr.md

[page_token]: ../guide/paging.md#tokens
[transactions/all]: ../endpoint/transactions_all.md
[transactions/single]: ../endpoint/transactions_single.md
[transactions/account]: ../endpoint/transactions_for_account.md
[transactions/ledgers]: ../endpoint/transactions_for_ledger.md
[ledgers/one]: ../endpoint/ledgers_single.md
[accounts/one]: ../endpoint/accounts_single.md
[operations/for_transaction]: ../endpoint/operations_for_transaction.md
[effects/for_transaction]: ../endpoint/effects_for_transaction.md
[operations]: ./operation.md
[concept_transactions]: https://github.com/stellar/docs/tree/master/docs/transaction.md
