---
id: not_implemented
title: Not Implemented
category: Errors
---

If your [request method](http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html) is not supported by Horizon, Horizon will return a `not_implemented` error. This is analogous to a [HTTP 501 Error](https://developer.mozilla.org/en-US/docs/Web/HTTP/Response_codes).

If you are encountering this error, Horizon does not have the functionality you are requesting yet.

## Attributes

As with all errors Horizon returns, `not_implemented` follows the [Problem Details for HTTP APIs](https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00) draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files. |


## Examples

```shell
$ curl -X GET 'https://horizon-testnet.stellar.org/ledgers/:200/effects'
{
  "type": "not_implemented",
  "title": "Resource Not Yet Implemented",
  "status": 404,
  "detail": "While the requested URL is expected to eventually point to a valid resource, the work to implement the resource has not yet been completed.",
  "instance": "horizon-testnet-001.prd.stellar001.internal.stellar-ops.com/hCYL7oezXs-141917"
}
```

## Related

[Server Error](./server-error.md)
