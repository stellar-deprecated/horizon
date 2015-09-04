---
id: payments_for_account
title: Payments for account
category: Endpoints
---

This endpoint responds with a collection of [Payment operations][] resources for the account specified in the arguments.  Specifically, any payment in which the specified account participates, either as sender or receiver.

This endpoint is particularly useful for following along with payments made by an [accounts][resources_account].  A client can retrieve quick notification about payments made to a specific account by using [response streaming][].

## Request

```
GET /accounts/{id}/payments{?cursor,limit,order}
```

### Arguments

|  name  |  notes  | description | example |
| ------ | ------- | ----------- | ------- |
| `id`      | required, string | The address of the account used to constrain results. | `GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ` |
| `?cursor` | optional, default _null_ | A payment paging token specifying from where to begin results. | `8589934592`                                          |
| `?limit`  | optional, number, default `10`  | Specifies the count of records at most to return. | `200` |
| `?order` | optional, string, default `asc` | Specifies order of returned results. `asc` means older payments first, `desc` mean newer payments first. | `desc` |

### curl Example Request

```bash
# Retrieve the 25 latest payments for a specific account.
curl https://horizon-testnet.stellar.org/account/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/payments?limit=25&order=desc
```

### JavaScript Example Request

```js
var StellarLib = require('js-stellar-sdk');
var server = new StellarLib.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.accounts("GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ")
  .then(function (accountResult) {
    console.log(accountResult);
  })
  .catch(function (err) {
    console.error(err);
  })
```
## Response

This endpoint responds with a [page][] of [payment operations][].

### Example Response

```json

{
  "_embedded": {
    "records": [
      {
        "_links": {
          "self": {
            "href": "/operations/12884905984"
          },
          "transaction": {
            "href": "/transaction/6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a"
          },
          "precedes": {
            "href": "/account/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/payments?cursor=12884905984&order=asc{?limit}",
            "templated": true
          },
          "succeeds": {
            "href": "/account/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/payments?cursor=12884905984&order=desc{?limit}",
            "templated": true
          }
        },
        "id": 12884905984,
        "paging_token": "12884905984",
        "type": 0,
        "type_s": "payment",
        "sender": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ",
        "receiver": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU",
        "currency": {
          "code": "XLM"
        },
        "amount": 1000000000,
        "amount_f": 100.00
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/account/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/payments?cursor=12884905984&order=asc{?limit}",
      "templated": true
    },
    "self": {
      "href": "/account/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/payments"
    }
  }
}

```

## Streaming

This endpoint can be also streaming data using [Server Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events).

Use [js-stellar-sdk](https://github.com/stellar/js-stellar-sdk/) to stream payments.

## Problems

This endpoint should only respond with [standard problems][].

## Tutorials

- [Follow payments sent to an account][]

[page]: ./resource/page.md
[Payment operations]: ./resource/operation.md#payment
[payment operations]: ./resource/operation.md#payment
[response streaming]: ../guide/response_streaming.md
[standard problems]: ../guide/problems.md#Standard_Problems
[resources_account]: ./resources/account.md
[resources_operation]: ./resources/operation.md
[Follow payments sent to an account]: tutorial/follow_received_payments.md
