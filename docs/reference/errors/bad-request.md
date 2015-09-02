---
id: bad_request
title: Bad Request
category: Errors
---

If Horizon cannot understand a request due to invalid syntax, it will return a `bad_request` error.  This is analogous to the [HTTP 400 Error][codes].

If you are encountering this error, please check to make sure your request syntax is correct.

## Attributes

As with all errors Horizon returns, `bad_request` follows the [Problem Details for HTTP APIs][guide] draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files  |

## Related

[Transaction Malformed](./transaction_malformed.md)

[codes]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Response_codes
[guide]: https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00
