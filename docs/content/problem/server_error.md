+++
date      = "2015-05-04T20:03:27-07:00"
draft     = false
linktitle = "Server Error"
title     = "Problem: Internal Server Error"
+++

A `server_error` problem is returned from horizon when an error occurs within
the code for horizon.  This error code is a catchall, and it could reflect any
number of errors in the server:  A configuration mistake, a database connection
error, a bug, etc.  

**NOTE: Even though Horizon is an open source project, we do not directly expose error information such as stack traces or raw error messages, as they may exposes sensitive configuration data such as secret keys.** 

## Example

```json
{
  "type":     "https://www.stellar.org/docs/horizon/problems/server_error",
  "title":    "Internal Server Error",
  "status":   500,
  "details":  "...",
  "instance": "d3465740-ec3a-4a0b-9d4a-c9ea734ce58a"
}
```

## Tips for resolution

- If you are encountering this problem on a server you control, please check the
  horizon log files for more details.  The logs should contain stack traces and
  more detailed information to help you discover the root issue.

- If encountering this problem on the public stellar infrastructure, report an
  issue on [horizon's issue tracker](#).  Please include at a minimum the
  `instance`   attribute from the problem response, but additional information
  such as the original request that triggered the problem is always welcome and
  speeds our ability to identify the problem.

