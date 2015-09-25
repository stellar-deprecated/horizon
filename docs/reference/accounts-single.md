---
id: accounts_single
title: Account Details
category: Endpoints
---

Returns information and links relating to a single [account](./resources/account.md).

## Request

```
GET /accounts/{account}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `account` | required, string | Account address | GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36 |

### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ
```

### JavaScript Example Request

```js
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.accounts()
  .address("GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ")
  .call()
  .then(function (accountResult) {
    console.log(accountResult);
  })
  .catch(function (err) {
    console.error(err);
  })
```

## Response

This endpoint responds with the details of a single account for a given address. See [account resource](./resources/account.md) for reference.

### Example Response
```json
{
  "_links": {
    "effects": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/effects/{?cursor,limit,order}",
      "templated": true
    },
    "offers": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/offers/{?cursor,limit,order}",
      "templated": true
    },
    "operations": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/operations/{?cursor,limit,order}",
      "templated": true
    },
    "self": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36"
    },
    "transactions": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/transactions/{?cursor,limit,order}",
      "templated": true
    }
  },
  "id": "GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36",
  "paging_token": "66035122180096",
  "address": "GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36",
  "sequence": 66035122176002,
  "balances": [
    {
      "asset_type": "native",
      "balance": 999999980
    }
  ]
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not_found.md): A `not_found` error will be returned if there is no account whose ID matches the `address` argument.


