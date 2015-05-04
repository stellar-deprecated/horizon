+++
date   = "2015-05-04T08:02:32-07:00"
draft  = true
title  = "Transaction Resource Type"
weight = 100
menu = ["main"]
+++

**Transaction** resources are the basic unit of change in the Stellar Network.

A transaction is a grouping of [operations][operations]. 

## Attributes

|     Attribute     |  Type  |                                                                                                                                |
| ----------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------ |
| id                | string | The canonical id of this transaction, suitable for use as the :id parameter for url templates that require a transaction's ID. |
| paging_token      | string | A [paging token][page_token] suitable for use as the `cursor` parameter to transaction collection resources.                    |
| hash              | string | A hex-encoded SHA-256 hash of the transaction's XDR-encoded form.                                                              |
| ledger            | number | Sequence number of the ledger in which this transaction was applied. `null` if the transaction is failed or unvalidated.        |
| account           | string |                                                                                                                                |
| account_sequence  | number |                                                                                                                                |
| max_fee           | number | The maximum fee willing to be paid by the transaction creator, expressed in a native currency amount.                           |
| fee_paid          | number | The fee paid by the source account of this transaction when the transaction was applied to the ledger.                          |
| operation_count   | number | The number of operations that are contained within this transaction.                                                            |
| result_code       | number | The numeric result code for this transaction                                                                                                                               |
| result_code_s     | string |                                                                                                                                 |
| result_code_human | string |                                                                                                                                |

## Links

|                   rel                    |                                           Example                                           |                             Relation                             |
| ---------------------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [self][transactions/one]                 | `/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a`            |                                                                  |
| [account][accounts/one]                  | `/accounts/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC`                             | The source account for this transaction.                         |
| [ledger][ledgers/one]                    | `/ledgers/3`                                                                                | The ledger in which this transaction was applied.                |
| [operations][operations/for_transaction] | `/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/operations` |                                                                  |
| [effects][effects/for_transaction]       | `/transactions/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a/effects`    |                                                                  |
| [precedes][transactions/many]            | `/transactions?cursor=12884905984&order=asc`                                                | A collection of transactions that occure after this transaction. |
| [succeeds][transactions/many]            | `/transactions?cursor=12884905984&order=desc`                                               | A collection of transactions that occur before this transaction. |


## Example

```json
//TODO
```

## Resources that provide transactions

|                 Resource                |    Type    |     Resource URL    |
| --------------------------------------- | ---------- | ------------------- |
| [All Transactions][transactions/many]   | Collection | `/transactions`     |
| [Transaction Details][transactions/one] | Single     | `/transactions/:id` |
|                                         |            |                     |

[page_token]:                 {{< relref "/guides/paging.md#tokens" >}}
[transactions/many]:          {{< relref "/resources/transactions/many.md" >}}
[transactions/one]:           {{< relref "/resources/transactions/one.md" >}}
[ledgers/one]:                {{< relref "/resources/ledgers/one.md" >}}
[accounts/one]:               {{< relref "/resources/accounts/one.md" >}}
[operations/for_transaction]: {{< relref "/resources/operations/for_transaction.md" >}}
[effects/for_transaction]:    {{< relref "/resources/effects/for_transaction.md" >}}
[operations]:                 {{< relref "/resource_types/operation.md" >}}


