---
id: server_error
title: Internal Server Error
category: Errors
---

If there's an internal error within Horizon, Horizon will return a `server_error` response.  This response is a catch-all, and can refer to many possible errors in the Horizon server: a configuration mistake, a database connection error, etc.

Horizon does not expose information such as stack traces or raw error messages to a client.  Doing so may reveal sensitive configuration data such as secret keys.

If you are encountering this error on a server you control, please check the Horizon log files for more details. The logs should contain detailed information to help you discover the root issue.

If you are encountering this error on the public Stellar infrastructure, please report an error on [Horizon's issue tracker](https://github.com/stellar/horizon/issues) and include the instance attribute.  Any other information, such as the request that triggered the response, would be most welcome.

## Attributes

As with all errors Horizon returns, `server_error` follows the [Problem Details for HTTP APIs][guide] draft specification guide and thus has the following attributes:

| Attribute | Type   | Description                                                                                                                     |
| --------- | ----   | ------------------------------------------------------------------------------------------------------------------------------- |
| Type      | URL    | The identifier for the error.  This is a URL that can be visited in the browser.                                                |
| Title     | String | A short title describing the error.                                                                                             |
| Status    | Number | An HTTP status code that maps to the error.                                                                                     |
| Detail    | String | A more detailed description of the error.                                                                                       |
| Instance  | String | A token that uniquely identifies this request. Allows server administrators to correlate a client report with server log files. |


## Examples
```json
{
  "type":     "https://www.stellar.org/docs/horizon/problems/server_error",
  "title":    "Internal Server Error",
  "status":   500,
  "details":  "...",
  "instance": "d3465740-ec3a-4a0b-9d4a-c9ea734ce58a"
}
```

## Related

[Not Implemented](./not_implemented.md)

[guide]: https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00

