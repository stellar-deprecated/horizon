---
id: not_acceptable
title: Not Acceptable
category: Errors
---

When your client only accepts certain formats of data from Horizon and Horizon cannot fulfill that request, Horizon will return a not_acceptable error.  This is analogous to the [HTTP 406 Error][codes].

If you are encountering this error, please check to make sure the criteria for content you’ll accept is correct.


## Attributes


As with all errors Horizon returns, `not_acceptable` follows the [Problem Details for HTTP APIs][guide] draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files  |


## Example

```bash
$ curl -X GET -H "Accept: application/xml" 'https://horizon-testnet.stellar.org/accounts/GALWEV6GY73RJ255JC7XUOZ2L7WZ5JJDTKATB2MUK7F3S67DVT2A6R5G'
{
  "type": "not_acceptable",
  "title": "An acceptable response content-type could not be provided for this request",
  "status": 406,
  "instance": "horizon-testnet-001.prd.stellar001.internal.stellar-ops.com/hCYL7oezXs-062662"
}
```

## Related

[Not Found][not_found]

[Forbidden][forbidden]

[not_found]: ./not_found.md
[forbidden]: ./forbidden.md
[codes]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Response_codes
[guide]: https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00
