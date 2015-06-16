---
id: problems
title: Problems
category: Guides
---

In the event that an error occurs while processing a request to horizon, a
**problem** response will be returned to the client.  This problem response will
contain information detailing why the request couldn't complete successfully.

Like HAL for successful responses, horizon uses a standard to specify how we
communicate errors to the client.  Specifically, horizon uses the [Problem
Details for HTTP APIs](https://tools.ietf.org/html/draft-ietf-appsawg-http-
problem-00) draft specification.  The specification is short, so we recommend
you read it.  In summary, when a problem occurs on the server we respond with a
json document with the following attributes:

|   name   |  type  |                                                                        description                                                                        |
| -------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| type     | url    | The identifier for the problem, expressed as a url.  Visiting the url in a web browser will redirect you to the additional documentation for the problem. |
| title    | string | A short title describing the problem.                                                                                                                     |
| status   | number | An HTTP status code that maps to the problem.  A problem that is triggered due to client input will be in the 400-499 range of status code, for exmaple.  |
| detail   | string | A longer description of the problem meant the further explain to problem to developers.                                                                   |
| instance | string | A token that uniquely identifies this request.  Allows server administrators to correlate a client report with server log files                           |
|          |        |                                                                                                                                                           |


<a id="standard_errors"></a>

## Standard Problems

There are a set of problems that can occur in any request to horizon which we
call **standard problems**.  These problems are:

- [Server Error]({{< relref "problem/server_error.md" >}})
- [Rate Limit Exceeded]({{< relref "problem/rate_limit_exceeded.md" >}})
- [Forbidden]({{< relref "problem/forbidden.md" >}})
