---
title: Before History
---

A horizon server may be configured to only keep a portion of the stellar network's history stored within its database.  This error will be returned when a client requests a piece of information (such as a page of transactions or a single operation) that the server can positively identify as falling outside the range of recorded history.

## Attributes

As with all errors Horizon returns, `before_history` follows the [Problem Details for HTTP APIs](https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00) draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files  |

## Example

```shell
$ curl -X GET "https://horizon-testnet.stellar.org/transactions?cursor=1&order=desc"
{
  "type": "before_history",
  "title": "Data Requested Is Before Recorded History",
  "status": 410,
  "detail": "This horizon instance is configured to only track a portion of the stellar network's latest history. This request is asking for results prior to the recorded history known to this horizon instance.",
  "instance": "horizon-testnet-001.prd.stellar001.internal.stellar-ops.com/ngUFNhn76T-078058"
}
```

## Related

[Not Found](./not-found.md)
