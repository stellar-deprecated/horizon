---
id: payments_for_account
title: Payments for account
category: Endpoints
---

This endpoint responds with a collection of [Payment operations][payment]
resources for the account specified in the arguments.  Specifically, any payment
in which the specified account participates, either as sender or receiver.

This endpoint is particularly useful for following along with payments made by
an account.  A client can retrieve quick notification about payments made to a
specific account by using [response streaming][rs].

## Request

```
GET /accounts/{id}/payments{?cursor}{?limit}{?order}
```

### Arguments

|  name  |  loc  |                 notes                  |                       example                       |                                                  description                                                  |
| ------ | ----- | -------------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| id     | path  | required, string                       | gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC | The address of the account used to constrain results.                                                         |
| cursor | query | optional, <br> default `""`            | 8589934592                                          | A payment paging token specifying from where to begin results.                                                |
| limit  | query | optional, number, <br> default `10`    | 500                                                 | Specifies the count of records at most to return.                                                             |
| order  | query | optional, string, <br> default `"asc"` | desc                                                | Specifies order of returned results.  `"asc"` means older payments first, `"desc"` mean newer payments first. |


### Example

```bash
# retrieve the first 25 payment for account

curl https://horizon-testnet.stellar.org/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments?limit=25
```

## Response

This endpoint responds with a [page][page] of [payment operations][payment].

### Example

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
            "href": "/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments?cursor=12884905984&order=asc{?limit}",
            "templated": true
          },
          "succeeds": {
            "href": "/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments?cursor=12884905984&order=desc{?limit}",
            "templated": true
          }
        },
        "id": 12884905984,
        "paging_token": "12884905984",
        "type": 0,
        "type_s": "payment",
        "sender": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC",
        "receiver": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ",
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
      "href": "/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments?cursor=12884905984&order=asc{?limit}",
      "templated": true
    },
    "self": {
      "href": "/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments"
    }
  }
}

```

### Problems

This endpoint should only respond with [standard errors][se].

## Tutorials

- [Follow payments sent to an account]({{< relref "tutorial/follow_received_payments.md" >}})

[page]: {{< relref "resource/page.md" >}}
[payment]: {{< relref "resource/operation.md" >}}#payment
[rs]: {{< relref "guide/response_streaming.md" >}}
[se]: {{< relref "guide/problems.md" >}}#standard_errors

