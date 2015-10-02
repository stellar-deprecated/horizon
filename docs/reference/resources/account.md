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
| paging_token | number           | A [paging token](./page.md) suitable for use as a `cursor` parameter.                                                                |
| address      | string           | The account' public key encoded into a base32 string representation.                                                    |
| sequence     | number           | The current sequence number that can be used when submitting a transaction from this account.                           |
| balances     | array of objects | An array of the native asset or credits this account holds.                                                          |

## Links
| rel          | Example                                                                                           | Description                                                | `templated` |
|--------------|---------------------------------------------------------------------------------------------------|------------------------------------------------------------|-------------|
| effects      | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/effects/{?cursor,limit,order}`      | The [effects](./effect.md) related to this account           | true        |
| offers       | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/offers/{?cursor,limit,order}`       | The [offers](./offer.md) related to this account             | true        |
| operations   | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/operations/{?cursor,limit,order}`   | The [operations](./operation.md) related to this account     | true        |
| transactions | `/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/transactions/{?cursor,limit,order}` | The [transactions](./transaction.md) related to this account | true        |


## Example

```json
{
  "_links": {
    "effects": {
      "href": "/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/effects/{?cursor,limit,order}",
      "templated": true
    },
    "offers": {
      "href": "/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/offers/{?cursor,limit,order}",
      "templated": true
    },
    "operations": {
      "href": "/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/operations/{?cursor,limit,order}",
      "templated": true
    },
    "self": {
      "href": "/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5"
    },
    "transactions": {
      "href": "/accounts/GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5/transactions/{?cursor,limit,order}",
      "templated": true
    }
  },
  "id": "GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5",
  "paging_token": "132564165595136",
  "address": "GAOEWNUEKXKNGB2AAOX6S6FEP6QKCFTU7KJH647XTXQXTMOAUATX2VF5",
  "sequence": 132564165591040,
  "balances": [
    {
      "asset_type": "native",
      "balance": 1000000000
    }
  ]
}
```

## Endpoints

| Resource                 | Type       | Resource URI Template                |
|--------------------------|------------|--------------------------------------|
| [All Accounts](../accounts-all.md)         | Collection | `/accounts`                          |
| [Account Details](../accounts-single.md)      | Single     | `/accounts/:id`                      |
| [Account Transactions](../transactions-for-account.md) | Collection | `/accounts/:account_id/transactions` |
| [Account Operations](../operations-for-account.md)   | Collection | `/accounts/:account_id/operations`   |
| [Account Payments](../payments-for-account.md)     | Collection | `/accounts/:account_id/payments`     |
| [Account Effects](../effects-for-account.md)      | Collection | `/accounts/:account_id/effects`      |
| [Account Offers](../offers-for-account.md)       | Collection | `/accounts/:account_id/offers`       |
