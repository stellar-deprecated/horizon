+++
date      = "2015-05-04T20:03:27-07:00"
draft     = false
linktitle = "Not Found"
title     = "Problem: Not Found"
+++

A `not_found` problem is returned from horizon when the resource a client is
requesting is not found.  This is similar to a "404 Not Found" error response
you get from HTTP.

## Example

```json
{
  "type":     "https://www.stellar.org/docs/horizon/problems/not_found",
  "title":    "Resource Missing",
  "status":   404,
  "details":  "The resource .... not found.",
  "instance": "d3465740-ec3a-4a0b-9d4a-c9ea734ce58a"
}
```

## Tips for resolution

- Ensure that the URL is correct, pay special attention to any path parameters,
  as this is usually where something is wrong.  Additionally, you should be 
  never see this error message when navigating from a link read from a response.

- Ensure the data exists. For example, if you are requesting the details of a
  transaction, you will receive a `not_found` error in the event that the 
  transaction you are requesting failed.

