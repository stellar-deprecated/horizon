---
title: Post Transaction
clientData:
  laboratoryUrl: https://www.stellar.org/laboratory/#explorer?resource=transactions&endpoint=create
---

Posts a new [transaction](./resources/transaction.md) to the Stellar Network.
Note that creating a valid transaction and signing it properly is the
responsibility of your client library.

Transaction submission and the subsequent validation and inclusion into the
Stellar Network's ledger is a [complicated and asynchronous
process](https://www.stellar.org/developers/learn/concepts/transactions.html#life-cycle).
To reduce the complexity, horizon manages these asynchronous processes for the
client and will wait to hear results from the Stellar Network before returning
an HTTP response to a client.

Transaction submission to horizon aims to be
[idempotent](https://en.wikipedia.org/wiki/Idempotence#Computer_science_meaning):
a client can submit a given transaction to horizon more than once and horizon
will behave the same each time.  If the transaction has already been
successfully applied to the ledger, horizon will simply return the saved result
and not attempt to submit the transaction again. Only in cases where a
transaction's status is unknown (and thus will have a chance of being included
into a ledger) will a resubmission to the network occur.

Information about [building transactions](https://www.stellar.org/developers/js-stellar-base/learn/building-transactions.html) in JavaScript.

## Request

```
POST /transactions
```

### Arguments

| name | loc  |  notes   |         example        | description |
| ---- | ---- | -------- | ---------------------- | ----------- |
| `tx` | body | required | `AAAAAO`....`f4yDBA==` | Base64 representation of transaction envelope [XDR](../learn/xdr.md) |


### curl Example Request

```sh
curl -X POST \
     -F "tx=AAAAAOo1QK/3upA74NLkdq4Io3DQAQZPi4TVhuDnvCYQTKIVAAAACgAAH8AAAAABAAAAAAAAAAAAAAABAAAAAQAAAADqNUCv97qQO+DS5HauCKNw0AEGT4uE1Ybg57wmEEyiFQAAAAEAAAAAZc2EuuEa2W1PAKmaqVquHuzUMHaEiRs//+ODOfgWiz8AAAAAAAAAAAAAA+gAAAAAAAAAARBMohUAAABAPnnZL8uPlS+c/AM02r4EbxnZuXmP6pQHvSGmxdOb0SzyfDB2jUKjDtL+NC7zcMIyw4NjTa9Ebp4lvONEf4yDBA==" \
  "https://horizon-testnet.stellar.org/transactions"
```

## Response

A successful response (i.e. any response with a successful HTTP response code)
indicates that the transaction was successful and has been included into the
ledger.

If the transaction failed or errored, then an error response will be returned. Please see the errors section below.

### Attributes

| Name              | Type   |                                                                       |
|-------------------|--------|-----------------------------------------------------------------------|
| `hash`            | string | A hex-encoded hash of the submitted transaction.                      |
| `ledger`          | number | The ledger number that the submitted transaction was included in.     |
| `envelope_xdr`    | string | A base64 encoded `TransactionEnvelope` [XDR](../learn/xdr.md) object. |
| `result_xdr`      | string | A base64 encoded `TransactionResult` [XDR](../learn/xdr.md) object.   |
| `result_meta_xdr` | string | A base64 encoded `TransactionMeta` [XDR](../learn/xdr.md) object.     |

### Example Response

```json
{
  "hash": "c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74",
  "ledger": 2,
  "envelope_xdr": "AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEAKZ7IPj/46PuWU6ZOtyMosctNAkXRNX9WCAI5RnfRk+AyxDLoDZP/9l3NvsxQtWj9juQOuoBlFLnWu8intgxQA",
  "result_xdr": "xJLYfEZCgV37PH3M4Br07/0WKwMQZAmKDXhrbgoA/XQAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==",
  "result_meta_xdr": "AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V4XYn/9gAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wFjRXgh7zX2AAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA=="
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [transaction_failed](./errors/transaction-failed.md): The transaction failed and could not be applied to the ledger.
- [transaction_malformed](./errors/transaction-malformed.md): The transaction could not be decoded and was not submitted to the network.
