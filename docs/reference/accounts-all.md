---
id: accounts_all
title: All Accounts
category: Endpoints
---

The all accounts endpoint returns a collection of all the [accounts][resources_account] that have ever existed. Results are ordered by account creation time. An address may show up multiple times if they were [merged][operations_accountMerge] and then [created][operations_createAccount] again.

## Request

```
GET /accounts{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc" | `asc` |
| `?limit` | optional, number, default `10` | Maximum number of records to return | `200` |

### curl Example Request

```shell
curl https://horizon-testnet.stellar.org/transactions?limit=200&order=desc
```

### JavaScript Example Request

```javascript
var StellarLib = require('js-stellar-sdk');
var server = new StellarLib.Server({hostname:'horizon-testnet.stellar.org', secure:true, port:443});

server.accounts()
  .then(function (accountResults) {
    //page 1
    console.log(accountResults.records)
    return accountResults.next()
  })
  .then(function (accountResults) {
    //page 2
    console.log(accountResults.records)
  })
  .catch(function (err) {
    console.log(err)
  })

```

## Response

Returns a returns a collection of [accounts][].

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "id": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "paging_token": "77309415424",
        "address": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO"
      },
      {
        "id": "GC2ADYAIPKYQRGGUFYBV2ODJ54PY6VZUPKNCWWNX2C7FCJYKU4ZZNKVL",
        "paging_token": "463856472064",
        "address": "GC2ADYAIPKYQRGGUFYBV2ODJ54PY6VZUPKNCWWNX2C7FCJYKU4ZZNKVL"
      },
      {
        "id": "GB4ZONAMYWRCU7KPV6A6DEPIY3YDZFVFTFC42XQGLWJQ53GQEDE3TI4C",
        "paging_token": "605590392832",
        "address": "GB4ZONAMYWRCU7KPV6A6DEPIY3YDZFVFTFC42XQGLWJQ53GQEDE3TI4C"
      },
      {
        "id": "GBC6OK4WVUKWUTHNJLKLYJ57G6UUQTJMHY2ON6R4DMRRCRDKYAWGH6CY",
        "paging_token": "31490700218368",
        "address": "GBC6OK4WVUKWUTHNJLKLYJ57G6UUQTJMHY2ON6R4DMRRCRDKYAWGH6CY"
      },
      {
        "id": "GC5BIFJBP5GTNYB3WHM7MA7J3Z2EF7VE7XCDU7V47AOZMGIBB4324W63",
        "paging_token": "35631048691712",
        "address": "GC5BIFJBP5GTNYB3WHM7MA7J3Z2EF7VE7XCDU7V47AOZMGIBB4324W63"
      },
      {
        "id": "GD7IDKHPOQJ2DFICCBSX5QEDSXSC5U7HRZLKNIXGCLDRRU5UOBEYABJO",
        "paging_token": "35927401435136",
        "address": "GD7IDKHPOQJ2DFICCBSX5QEDSXSC5U7HRZLKNIXGCLDRRU5UOBEYABJO"
      },
      {
        "id": "GBSN5O2Q47RDWKANTBK5PZAOMHMQQZE53LS32OKCBY6XGXZSFAVD7SUR",
        "paging_token": "46269682683904",
        "address": "GBSN5O2Q47RDWKANTBK5PZAOMHMQQZE53LS32OKCBY6XGXZSFAVD7SUR"
      },
      {
        "id": "GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB",
        "paging_token": "46316927324160",
        "address": "GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB"
      },
      {
        "id": "GAKLBGHNHFQ3BMUYG5KU4BEWO6EYQHZHAXEWC33W34PH2RBHZDSQBD75",
        "paging_token": "46428596473856",
        "address": "GAKLBGHNHFQ3BMUYG5KU4BEWO6EYQHZHAXEWC33W34PH2RBHZDSQBD75"
      },
      {
        "id": "GBAP36MOHWTXNGO6I6UYUXSOF7AA2PA5Y26PJW6VG7CVDFQPIX243ILV",
        "paging_token": "46669114642432",
        "address": "GBAP36MOHWTXNGO6I6UYUXSOF7AA2PA5Y26PJW6VG7CVDFQPIX243ILV"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/accounts?order=asc&limit=10&cursor=46669114642432"
    },
    "prev": {
      "href": "/accounts?order=desc&limit=10&cursor=77309415424"
    },
    "self": {
      "href": "/accounts?order=asc&limit=10&cursor="
    }
  }
}
```

## errors

- The [standard errors][].

[page]: ./resource/paging.md
[accounts]: ./resource/account.md
[operations_accountMerge]: ./resource/operations.md#Account_Merge
[operations_createAccount]: ./resource/operations.md#Create_Account
[resources_account]: ./resources/account.md
[standard errors]: ../guide/errors.md#Standard_Errors
