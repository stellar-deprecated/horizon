---
id: transaction_malformed
title: Transaction Malformed
category: Errors
---

When you submit a malformed transaction to Horizon, Horizon will return a `transaction_malformed` error.  There are many ways in which a transaction is malformed, including
* you submitted an empty string
* your hex-encoded string is invalid
* your [XDR](../../guide/xdr.md) structure is invalid
* you have leftover bytes in your [XDR](../../guide/xdr.md) structure

If you are encountering this error, please check the contents of the transaction you are submitting.  This error is similar to the [Bad Request][bad_request] error response and, therefore, the [HTTP 400 Error][codes].

## Attributes

As with all errors Horizon returns, `transaction_malformed` follows the [Problem Details for HTTP APIs][guide] draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files. |


## Related

[Bad Request][bad_request]

[bad_request]: ./bad_request.md
[codes]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Response_codes
[guide]: https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00
[XDR]: ../guide/xdr.md
