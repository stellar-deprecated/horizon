---
title: Payments for account
---

This endpoint responds with a collection of [Payment operations](./resources/operation.md) where the given [account](./resources/account.md) was either the sender or receiver.

This endpoint can also be used in [streaming](../learn/responses.md#streaming) mode so it is possible to use it to listen for new payments to or from an account as they get made in the Stellar network.

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
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.payments()
  .forAccount("GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ")
  .call()
  .then(function (accountResult) {
    console.log(accountResult);
  })
  .catch(function (err) {
    console.error(err);
  })
```
## Response

This endpoint responds with a [page](./resources/page.md) of [payment operations](./resources/operation.md).

### Example Response

```json
{"_embedded": {
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
      "asset": {
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



## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
