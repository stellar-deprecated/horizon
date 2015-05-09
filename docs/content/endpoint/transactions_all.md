+++
date  = "2015-05-04T20:04:06-07:00"
draft = true
title = "All Transactions"
+++

This endpoint represents all validated transactions. 

## Arguments

|    name   |  type  | default |                            description                            |   example   |
| --------- | ------ | ------- | ----------------------------------------------------------------- | ----------- |
| `?cursor` | any    |         | A paging token, specifying where to start returning records from. | 12884905984 |
| `?order`  | string | asc     | The order in which to return rows, "asc" or "desc"                | asc         |
| `?limit`  | number | 10      | Maximum number of records to return                                                                  | 100         |


## Example Requests

Retrieve the first 200 transactions, ordered chronologically
```bash
$ curl https://horizon-testnet.stellar.org/transactions?limit=200
```

Retrieve a page of transactions to occur immediately before the transaction 
identified by the paging token "1234"
```bash
$ curl https://horizon-testnet.stellar.org/transactions?cursor=1234&order=desc
```

## Response

This endpoint returns a page of [transactions][transaction].  For simple http 
requests, these 

## Problems

TODO

[transaction]: {{< relref "resource/transaction.md" >}}
