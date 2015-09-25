---
id: transactions_create
title: Post Transaction
category: Endpoints
---

Posts a new [transaction](./resources/transaction.md) to the Stellar Network.  Note that creating a valid
transactions and signing it properly is the responsibility of your
client library.

Also note, this endpoint is presently a very thin wrapper around the raw
transaction submission endpoint in stellar-core.  This endpoint will probably
change quite soon to reflect more of the design choices made by the rest of
horizon

## Request

```
POST /transactions
```

### Arguments

| name | loc  |  notes   |                                                                                                                                                                                                                 example                                                                                                                                                                                                                  | description |
| ---- | ---- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `tx` | body | required | `AAAAAO`....`f4yDBA==` | Base64 representation of transaction envelope [XDR][] |


### curl Example Request

```sh
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"tx": "AAAAAOo1QK/3upA74NLkdq4Io3DQAQZPi4TVhuDnvCYQTKIVAAAACgAAH8AAAAABAAAAAAAAAAAAAAABAAAAAQAAAADqNUCv97qQO+DS5HauCKNw0AEGT4uE1Ybg57wmEEyiFQAAAAEAAAAAZc2EuuEa2W1PAKmaqVquHuzUMHaEiRs//+ODOfgWiz8AAAAAAAAAAAAAA+gAAAAAAAAAARBMohUAAABAPnnZL8uPlS+c/AM02r4EbxnZuXmP6pQHvSGmxdOb0SzyfDB2jUKjDtL+NC7zcMIyw4NjTa9Ebp4lvONEf4yDBA=="}' \
  https://horizon-testnet.stellar.org/transactions
```

## Response

This endpoint returns a resource that represents the result of initial
submission of the provided transaction to stellar-core.

### Attributes

|         Name        |  Type  |                                                               |
| ------------------- | ------ | ------------------------------------------------------------- |
| `hash`              | string | A hex-encoded hash of the submitted transaction.              |
| `result`            | string | Distilled summary of the result.  See "Result" section below. |
| `submission_result` | string | A base64 encoded `TransactionResult` [XDR](../guide/xdr.md) object.                 |

### Result

The `result` attribute of a response from this endpoint can be one of the following values:

| `result`         |                                                                                                                                             |
| -----------------| --------------------------------------------------------------------------------------------------------------------------                  |
| malformed        | The transaction was sufficiently malformed that we could not interpret it.                                                                  |
| already_finished | The hash for this transaction hash is either in the history database or is in the stellar-core database.                 |
| received         | The transaction was submitted and received by stellar core, and will be included in consideration for a validated [ledger](./resources/ledger.md)|
| failed           | The submission to stellar core failed, and was not received by the network.  Refer to the `submission_result` for details.                  |
| connection_failed| Horizon could not connect to stellar core.                                                                                                  |


### Example Response

```json
{
    "hash": "6136e1236bbba250648c511806a33e3adec8597840827e6cb568feae7680c921",
    "result": "failed",
    "error":"AAAAAAAAAAr////6AAAAAA=="
}
```

## Possible Errors

- The [standard errors](../guide/errors.md#Standard_Errors).

