---
title: Not Found
---

When Horizon can't find whatever you are requesting, it will return a `not_found` error. This is similar to a ["404 Not Found"](https://developer.mozilla.org/en-US/docs/Web/HTTP/Response_codes) error response in HTTP.

Incorrect URL path parameters or missing data are the common reasons for this error. If you navigate using a link from a valid response, you should never receive this error message.

## Attributes

As with all errors Horizon returns, `not_found` follows the [Problem Details for HTTP APIs](https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00) draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files  |

## Example

```shell
$ curl -X GET "https://horizon-testnet.stellar.org/accounts/accountthatdoesntexist"
{
  "type": "not_found",
  "title": "Resource Missing",
  "status": 404,
  "detail": "The resource at the url requested was not found.  This is usually occurs for one of two reasons:  The url requested is not valid, or no data in our database could be found with the parameters provided.",
  "instance": "horizon-testnet-001.prd.stellar001.internal.stellar-ops.com/ngUFNhn76T-078058"
}
```

## Related

[Not Acceptable](./not-acceptable.md)

[Forbidden](./forbidden.md)
