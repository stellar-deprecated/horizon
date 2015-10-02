---
title: Transaction Failed
---

This error occurs when a client submits a transaction that was well-formed but was not included into the ledger due to some other failure. For example, a transaction may fail if:

- The source account for transaction cannot pay the minimum fee.
- The sequence number is incorrect.
- One of the contained operations has failed such as a payment operation that overdraws the paying account.

In almost every case, this error indicates that the transaction submitted in the initial request will never succeed.  There is one exception: a transaction that fails with the `tx_bad_seq` result code (as expressed in the `result_code` field of the error) may become valid in the future if the sequence number it used was too high.

## Attributes

As with all errors Horizon returns, `transaction_failed` follows the [Problem Details for HTTP APIs](https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00) draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files. |

In addition, the following additional data is provided in the `extras` field of the error:

| Attribute         | Type   | Description                                                                                                                 |
|-------------------|--------|-----------------------------------------------------------------------------------------------------------------------------|
| `envelope_xdr`    | String | A base64-encoded representation of the TransactionEnvelope XDR whose failure triggered this response.                       |
| `result_xdr`      | String | A base64-encoded representation of the TransactionResult XDR returned by stellar-core when submitting this transactions.    |
| `result_code`     | String | The transaction result code returned by stellar-core.                                                                       |
| `op_result_codes` | Array  | An array of strings, representing the operation result codes for each operation in the submitted transaction, if available. |


## Example
```json
{
  "type":     "https://stellar.org/horizon-errors/transaction_failed",
  "title":    "Transaction Failed",
  "status":   400,
  "details":  "...",
  "instance": "d3465740-ec3a-4a0b-9d4a-c9ea734ce58a",
	"extras": {
		"envelope_xdr": "...",
		"result_xdr": "...",
		"result_code": "tx_failed",
		"op_result_codes": [ "op_bad_auth" ]
	}
}
```

## Related

- [Transaction Malformed](./transaction-malformed.md)
