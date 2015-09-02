---
id: accounts_single
title: Account Details
category: Endpoints
---

Returns information and links relating to a single [account][resources_account].

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
var StellarLib = require('js-stellar-lib');
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

This endpoint responds with the details of a single account for a given address. See [account resource][] for reference.

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
      "currency_type": "native",
      "balance": 999999980
    }
  ]
}
```

## Errors

- The [standard errors][].
- [not_found][errors/not_found]: A `not_found` error will be returned if there is no account whose ID matches the `address` argument.

[account resource]: ./resource/account.md
[resources_account]: ./resources/account.md
[errors/not_found]: ../errors/not_found.md
[standard error]: ../guide/errors.md#Standard_Errors
