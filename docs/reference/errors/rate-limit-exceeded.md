---
id: rate_limit_exceeded
title: Rate Limit Exceeded
category: Errors
---

When a single user makes too many requests to Horizon in a one hour time frame, Horizon returns a `rate_limit_exceeded` error.  By default, Horizon allows 3600 requests per hour -- an average of one request per second.

If you are encountering this error, please reduce your request speed.  Here are some strategies for doing so:
* For collection endpoints, try specifying larger page sizes.
* Try streaming responses to watch for new data instead of pulling data every time.
* Cache immutable data, such as transaction details, locally

See the [Rate Limiting Guide](../../guide/rate-limiting.md) for more info.

## Attributes

As with all errors Horizon returns, `rate_limit_exceeded` follows the [Problem Details for HTTP APIs](https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00) draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files. |

Examples
```json
{
  "type":     "https://www.stellar.org/docs/horizon/problems/rate_limit_exceeded",
  "title":    "Rate Limit Exceeded",
  "status":   429,
  "details":  "...",
  "instance": "d3465740-ec3a-4a0b-9d4a-c9ea734ce58a"
}
```


