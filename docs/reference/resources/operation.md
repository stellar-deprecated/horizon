---
id: operation
title: Operation
category: Resources
---

[Operations](https://github.com/stellar/docs/blob/master/concepts/operations.md) are objects that represent a desired change to the ledger: payments,
offers to exchange currency, changes made to account options, etc.  Operations
are submitted to the Stellar network grouped in a [Transaction](./resources/transaction.md).

To learn more about the concept of operations in the Stellar network, take a look at the [Stellar operations concept guide](https://github.com/stellar/docs/blob/master/concepts/operations.md).

## Operation Types

There are 10 different operation types:

|     type_s           | type | description |
| -------------------- | ---- |-------------|
| [CREATE_ACCOUNT](#create-account)       |    0 | Creates a new account in Stellar network.
| [PAYMENT](#payment)              |    1 | Sends a simple payment between two accounts in Stellar network.
| [PATH_PAYMENT](#path-payment)         |    2 | Sends a path payment between two accounts in the Stellar network.
| [MANAGE_OFFER](#manage-offer)         |    3 | Creates, updates or deletes an offer in the Stellar network.
| [CREATE_PASSIVE_OFFER](#create-passive-offer) |    4 | Creates an offer that won't consume a counter offer that exactly matches this offer.
| [SET_OPTIONS](#set-options)          |    5 | Sets account options (inflation destination, adding signers, etc.)
| [CHANGE_TRUST](#change-trust)         |    6 | Creates, updates or deletes a trust line.
| [ALLOW_TRUST](#allow-trust)          |    7 | Updates the "authorized" flag of an existing trust line this is called by the issuer of the related currency.
| [ACCOUNT_MERGE](#account-merge)        |    8 | Deletes account and transfers remaining balance to destination account.
| [INFLATION](#inflation)            |    9 | Runs inflation.


Every operation type shares a set of common attributes and links, some operations also contain
additional attributes and links specific to that operation type.



## Common Attributes

|               |  Type  |                                                                                                                            |
| ------------- | ------ | -------------------------------------------------------------------------------------------------------------------------- |
| id            | number | The canonical id of this operation, suitable for use as the :id parameter for url templates that require an operation's ID. |
| paging_token  | any    |                                                                                                                            |
| type          | number | Specifies the type of operation, See "Types" section below for reference.                                                  |
| type_s        | string | A string representation of the type of operation.                                                                           |

## Common Links

|             | Example |                  Relation                 |
| ----------- | ------- | ----------------------------------------- |
| self        |         | Relative link to the current operation    |
| succeeds    |         | Relative link to the list of operations succeeding the current operation. |
| precedes    |         | Relative link to the list of operations preceding the current operation. |
| transaction |         | The transaction this operation is part of |



Each operation type will have a different set of attributes, in addition to the
common attributes listed above.


### Create Account

Create Account operation represents a new account creation.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
| id     | int64 | Operation ID. |
| account     | AccountID | A new account that was funded. |
| funder     | AccountID | Account that funded a new account. |
| starting_balance | int64 | Amount the account was funded. |


#### Example
```json
{
  "_links": {
    "effects": {
      "href": "/operations/402494270214144/effects/{?cursor,limit,order}",
      "templated": true
    },
    "precedes": {
      "href": "/operations?cursor=402494270214144&order=asc"
    },
    "self": {
      "href": "/operations/402494270214144"
    },
    "succeeds": {
      "href": "/operations?cursor=402494270214144&order=desc"
    },
    "transactions": {
      "href": "/transactions/402494270214144"
    }
  },
  "account": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ",
  "funder": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
  "id": 402494270214144,
  "paging_token": "402494270214144",
  "starting_balance": 1000000000,
  "type": 0,
  "type_s": "create_account"
}
```


### Payment

A payment operation represents a payment from one account to another.  This payment
can be either a simple native currency payment or a fiat currency payment.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
| from          | string | Sender of a payment.  |
| to     | string | Destination of a payment. |
| asset_type        | string/object | “native” for stellars |
| amount          | number | Amount sent. |

#### Links

|          |                            Example                            |      Relation     |
| -------- | ------------------------------------------------------------- | ----------------- |
| sender   | /accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2  | Sending account   |
| receiver | /accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ | Receiving account |

#### Example

```json
{
  "_links": {
    "effects": {
      "href": "/operations/58402965295104/effects/{?cursor,limit,order}",
      "templated": true
    },
    "precedes": {
      "href": "/operations?cursor=58402965295104&order=asc"
    },
    "self": {
      "href": "/operations/58402965295104"
    },
    "succeeds": {
      "href": "/operations?cursor=58402965295104&order=desc"
    },
    "transactions": {
      "href": "/transactions/58402965295104"
    }
  },
  "amount": 300000000,
  "currency_type": "native",
  "from": "GAKLBGHNHFQ3BMUYG5KU4BEWO6EYQHZHAXEWC33W34PH2RBHZDSQBD75",
  "id": 58402965295104,
  "paging_token": "58402965295104",
  "to": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ",
  "type": 1,
  "type_s": "payment"
}
```


### Path Payment

A payment operation represents a payment from one account to another through a path.  This type of payment starts as one type of asset and ends as another type of asset. There can be other assets that are traded into and out of along the path.
 

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
| from          | string | Sender of a payment.  |
| to     | string | Destination of a payment. |
| asset_type        | string/object | “native” for stellars |
| amount          | number | Amount sent. |

#### Links

|          |                            Example                            |      Relation     |
| -------- | ------------------------------------------------------------- | ----------------- |
| sender   | /accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2  | Sending account   |
| receiver | /accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ | Receiving account |

#### Example

```json
{
  "_links": {
    "effects": {
      "href": "/operations/54554674597889/effects/{?cursor,limit,order}",
      "templated": true
    },
    "precedes": {
      "href": "/operations?cursor=54554674597889&order=asc"
    },
    "self": {
      "href": "/operations/54554674597889"
    },
    "succeeds": {
      "href": "/operations?cursor=54554674597889&order=desc"
    },
    "transactions": {
      "href": "/transactions/54554674597888"
    }
  },
  "amount": 2e+16,
  "currency_type": "native",
  "from": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ",
  "id": 54554674597889,
  "paging_token": "54554674597889",
  "to": "GCB2NV2O2TMC3CMTIZ3MIAKEIGC75LZ7LNX3TKWTI24KOBIAWXROWLRO",
  "type": 1,
  "type_s": "payment"
}
```

### Manage Offer

A "Manage Offer" operation can create, update or delete an
offer to trade assets in the Stellar network.
It specifies an issuer, a price and amount of a given asset to
buy or sell.

When this operation is applied to the ledger, trades can potentially be executed if
this offer crosses others that already exist in the ledger.

In the event that there are not enough crossing orders to fill the order completely
a new "Offer" object will be created in the ledger.  As other accounts make
offers or payments, this offer can potentially be filled.

To update the offer provide existing offer ID in `offerID` field.

To delete the offer change amount of the offer to `0`.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
| id     | int64 | Operation ID. |
| offer_id | int64 | Offer ID. |
| amount     | int64 | Amount of asset to be sold. |
| price | Object | n: price numerator, d: price denominator |


#### Links

|           | Example |                Relation               |
| --------- | ------- | ------------------------------------- |
| orderbook |         | The orderbook the offer was posted to |

#### Example

```json
{
  "_links": {
    "effects": {
      "href": "/operations/1777609654407168/effects/{?cursor,limit,order}",
      "templated": true
    },
    "precedes": {
      "href": "/operations?cursor=1777609654407168\u0026order=asc"
    },
    "self": {
      "href": "/operations/1777609654407168"
    },
    "succeeds": {
      "href": "/operations?cursor=1777609654407168\u0026order=desc"
    },
    "transactions": {
      "href": "/transactions/1777609654407168"
    }
  },
  "amount": 100,
  "id": 1777609654407168,
  "offer_id": 0,
  "paging_token": "1777609654407168",
  "price": {
    "d": 1,
    "n": 2
  },
  "type": 3,
  "type_s": "manage_offer"
}
```

### Create Passive Offer

“Create Passive Offer” operation creates an offer that won't consume a counter offer that exactly matches this offer. This is useful for offers just used as 1:1 exchanges for path payments. Use Manage Offer to manage this offer after using this operation to create it.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
|                 |        |                   |


<a id="set_options"></a>
### Set Options

Use “Set Options” operation to set following options to your account:
* Set/clear account flags:
  * AUTH_REQUIRED_FLAG (0x1) - if set, TrustLines are created with authorized set to "false" requiring the issuer to set it for each TrustLine.
  * AUTH_REVOCABLE_FLAG (0x2) - if set, the authorized flag in TrustLines can be cleared otherwise, authorization cannot be revoked.
* Set the account’s inflation destination.
* Add new signers to the account.


#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
| signer_key | string | The address of the new signer. |
| signer_weight | int | The weight of the new signer (1-255). |


### Change Trust

Use “Change Trust” operation to create/update/delete a trust line from the source account to another. The issuer being trusted and the asset code are in the given Asset object.

To delete a trust line set `limit` parameter to `0`.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
| asset_code | string | Asset code. |
| asset_issuer | string | Asset issuer. |
| asset_type | string | Asset type (native/ alphanum4 / alphanum12) |
| trustee | string | Trustee account. |
| trustor | string | Trustor account. |
| limit | string | The limit for the asset. |


<a id="allow_trust"></a>
### Allow Trust

Updates the "authorized" flag of an existing trust line this is called by the issuer of the asset.

Heads up! Unless the issuing account has AUTH_REVOCABLE_FLAG set than the "authorized" flag can only be set and never cleared.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
|                 |        |                   |

### Account Merge

Removes the account and transfers all remaining lumens to the destination account.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
|                 |        |                   |




### Inflation

Runs inflation.

#### Attributes

| Field           |  Type  | Description       |
| --------------- | ------ | ----------------- |
|                 |        |                   |




## Endpoints

|                   Resource                   |    Type    |            Resource URI Template            |
| -------------------------------------------- | ---------- | ---------------------------------- |
| [All Operations](../operations-all.md)            | Collection | `/operations`                      |
| [Operations Details](../operations-single.md)      | Single     | `/operations/:id`                  |
| [Ledger Operations](../operations-for-ledger.md)   | Collection | `/ledgers/{id}/operations{?cursor,limit,order}` |
| [Account Operations](../operations-for-account.md) | Collection | `/accounts/:account_id/operations` |
| [Account Payments](../payments-for-account.md)     | Collection | `/accounts/:account_id/payments` |

