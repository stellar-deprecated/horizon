+++
draft     = false
linktitle = "Rate Limit Exceeded"
title     = "Problem: Rate Limit Exceeded"
+++

A `rate_limit_exceeded` problem is returned from horizon when it receives too
many requests within a one hour window from a single user.  By default, horizon
allows 3600 requests per hour, an average of one per second.

See the [rate limiting guide][rlg] for more info.

## Example

```json
{
  "type":     "https://www.stellar.org/docs/horizon/problems/rate_limit_exceeded",
  "title":    "Rate Limit Exceeded",
  "status":   429,
  "details":  "...",
  "instance": "d3465740-ec3a-4a0b-9d4a-c9ea734ce58a"
}
```

## Tips for resolution

Fundamentally, you need to reduce the number of requests you make to horizon per
hour.  Here are some strategies to help you do this:

- For collection endpoints, specify larger page sizes.
- Use streaming responses to watch for new data rather than polling.
- Locally cache immutable data, such as a transaction's details.

[rlg]: {{< relref "guide/rate_limiting.md" >}}
