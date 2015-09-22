---
id: offers_for_account
title: Offers for account
category: Endpoints
---

People on the Stellar network can make [offers](http://stellar.org/developers/learn/concepts/exchange/) to buy or sell assets. 

## Request

```
GET /accounts/{account}/offers{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc". | `asc` |
| `?limit`  | optional, number, default: `10` | Maximum number of records to return. | `200` |

## Possible Errors

- The [standard errors](../guide/errors.md#Standard_Errors).
