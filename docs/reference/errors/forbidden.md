---
id: forbidden
title: Forbidden
category: Errors
---

If you request data from Horizon you are not authorized to see, Horizon will return a `forbidden` error response. This is analogous to a [HTTP 403
Error][codes].

If you are encountering this error, please check your request and make sure you have permission to receive that data.

## Attributes

As with all errors Horizon returns, `forbidden` follows the [Problem Details for HTTP APIs](https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00) draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files  |


## Related

[Not Found](./not-found.md)
[Not Acceptable](./not-acceptable.md)
