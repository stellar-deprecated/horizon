---
title: Account
---

In the Stellar network, users interact using **accounts** which can be controlled by a corresponding keypair that can authorize transactions. One can create a new account with the [Create Account](./operation.md#create-account) operation.

To learn more about the concept of accounts in the Stellar network, take a look at the [Stellar account concept guide](https://www.stellar.org/developers/learn/concepts/accounts.html).

When horizon returns information about an account it uses the following format:

## Attributes
| Attribute    | Type             |                                                                                                                        |
|--------------|------------------|------------------------------------------------------------------------------------------------------------------------|
| id           | string           | The canonical id of this account, suitable for use as the :id parameter for url templates that require an account's ID. |
| account_id      | string           | The account's public key encoded into a base32 string representation.                                                    |
| sequence     | number           | The current sequence number that can be used when submitting a transaction from this account.                           |
| subentry_count     | number           | The number of [account subentries](https://www.stellar.org/developers/guides/concepts/ledger.html#ledger-entries). |
| balances     | array of objects | An array of the native asset or credits this account holds.                                                          |
| thresholds     | object | An object of account flags. |
| signers     | array of objects | An array of account signers with their weights. |
| data     | object | An array of account data fields. |

## Links
| rel          | Example                                                                                           | Description                                                | `templated` |
|--------------|---------------------------------------------------------------------------------------------------|------------------------------------------------------------|-------------|
| data      | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/data/{key}`      | [Data fields](./data.md) related to this account           | true        |
| effects      | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/effects/{?cursor,limit,order}`      | The [effects](./effect.md) related to this account           | true        |
| offers       | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/offers/{?cursor,limit,order}`       | The [offers](./offer.md) related to this account             | true        |
| operations   | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/operations/{?cursor,limit,order}`   | The [operations](./operation.md) related to this account     | true        |
| payments   | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/payments/{?cursor,limit,order}`   | The [payments](./payment.md) related to this account     | true        |
| trades | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/trades/{?cursor,limit,order}` | The [trades](./trade.md) related to this account | true        |
| transactions | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/transactions/{?cursor,limit,order}` | The [transactions](./transaction.md) related to this account | true        |


## Example

```json
{
  "_links": {
    "self": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23"
    },
    "transactions": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23/transactions{?cursor,limit,order}",
      "templated": true
    },
    "operations": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23/operations{?cursor,limit,order}",
      "templated": true
    },
    "payments": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23/payments{?cursor,limit,order}",
      "templated": true
    },
    "effects": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23/effects{?cursor,limit,order}",
      "templated": true
    },
    "offers": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23/offers{?cursor,limit,order}",
      "templated": true
    },
    "trades": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23/trades{?cursor,limit,order}",
      "templated": true
    },
    "data": {
      "href": "https://horizon-testnet.stellar.org/accounts/GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23/data/{key}",
      "templated": true
    }
  },
  "id": "GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23",
  "paging_token": "",
  "account_id": "GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23",
  "sequence": "26509955490119684",
  "subentry_count": 1,
  "thresholds": {
    "low_threshold": 0,
    "med_threshold": 0,
    "high_threshold": 0
  },
  "flags": {
    "auth_required": false,
    "auth_revocable": false
  },
  "balances": [
    {
      "balance": "9999.9999600",
      "asset_type": "native"
    }
  ],
  "signers": [
    {
      "public_key": "GBRTWTVW65NO4AER7W6G5CTVWGZCLQJIKJTAX523Q5GPU6TNJONXOR23",
      "weight": 1
    }
  ],
  "data": {
    "club": "MTAw"
  }
}
```

## Endpoints

| Resource                 | Type       | Resource URI Template                |
|--------------------------|------------|--------------------------------------|
| [Account Details](../accounts-single.md)      | Single     | `/accounts/:id`                      |
| [Account Data](../data-for-account.md)      | Single     | `/accounts/:id/data/:key`                      |
| [Account Transactions](../transactions-for-account.md) | Collection | `/accounts/:account_id/transactions` |
| [Account Operations](../operations-for-account.md)   | Collection | `/accounts/:account_id/operations`   |
| [Account Payments](../payments-for-account.md)     | Collection | `/accounts/:account_id/payments`     |
| [Account Effects](../effects-for-account.md)      | Collection | `/accounts/:account_id/effects`      |
| [Account Offers](../offers-for-account.md)       | Collection | `/accounts/:account_id/offers`       |
