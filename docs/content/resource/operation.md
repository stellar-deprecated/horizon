+++
title = "Operation"
draft = false
+++

Operations are objects that represent a desired change to the ledger: payments,
offers to exchange currency, changes made to account options, etc.  Operations
are submitted to the Stellar Network grouped in a [Transaction][transactions].

An operation is one of six types: Payment, Create Offer, Set Options, Change 
Trust, Allow Trust, Account Merge, and Inflation.  See the section "Operation 
Types" below.

Every operation type share a set of common attributes and links, but contain
additional attributes and links specific to its types.

## Common Attributes

|               |  Type  |                                                                                                                            |
| ------------- | ------ | -------------------------------------------------------------------------------------------------------------------------- |
| id            | number | The canonical id of this operation, suitable for use as the :id parameter for url templates that require an operation's ID |
| paging_token  | any    |                                                                                                                            |
| type          | number | Specifies the type of operation, See "Types" section below for reference.                                                  |
| type_s        | string | A string representation of the type of operation                                                                           |

## Common Links

|             | Example |                  Relation                 |
| ----------- | ------- | ----------------------------------------- |
| self        |         |                                           |
| succeeds    |         |                                           |
| precedes    |         |                                           |
| transaction |         | The transaction this operation is part of |


## Operation Types

There are sevent different operation types: 

|     type_s    | type |
| ------------- | ---- |
| payment       |    0 |
| create_offer  |    1 |
| set_options   |    2 |
| change_trust  |    3 |
| allow_trust   |    4 |
| account_merge |    5 |
| inflation     |    6 |

Each operation type will have a different set of attributes, in addition to the 
common attributes listed above.

<a id="payment"></a>

### Payment

A payment operation represents a payment from one account to another.  This payment
can be either a simple native currency payment or a fiat currency payment.

#### Attributes

|                 |  Type  |                   |
| --------------- | ------ | ----------------- |
| sender          | string | address of sender |
| receiver        | string |                   |
| currency        | object |                   |
| currency.code   | string |                   |
| currency.issuer | string |                   |
| amount          | number |                   |
| amount_f        | number |                   |
| path            | array  |                   |

#### Links

|          |                            Example                            |      Relation     |
| -------- | ------------------------------------------------------------- | ----------------- |
| sender   | /accounts/gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA  | Sending account   |
| receiver | /accounts/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC | Receiving account |

#### Example

```json
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
```

### Create Offer

A "Create Offer" operation represents the desire of an account to trade 
currencies. It specifies an order book, a price and amount of currency to 
buy or sell.

When this operation is applied to the ledger, trades will be executed by
matching this operation with crossing offers, executing trades in an attempt to
completely will this offer.

In the event that there are not enough crossing orders to fill the order completely
a new "Offer" object will be created in the ledger.  As other accounts make
offers or payments, this offer will be filled when possible.

#### Attributes

|     | Type |     |
| --- | ---- | --- |
|     |      |     |
  

#### Links

|           | Example |                Relation               |
| --------- | ------- | ------------------------------------- |
| orderbook |         | The orderbook the offer was posted to |
|           |         |                                       |


### Set Options

TODO

### Change Trust

TODO

### Allow Trust

TODO

### Account Merge

TODO

### Inflation

TODO

## Endpoints

|                   Resource                   |    Type    |            Resource URL            |
| -------------------------------------------- | ---------- | ---------------------------------- |
| [All Operations][operations_all]             | Collection | `/operations`                      |
| [Operations Details][operations_single]      | Single     | `/operations/:id`                  |
| [Account Operations][operations_for_account] | Collection | `/accounts/:account_id/operations` |
| [Account Payments][payments_for_account]     | Collection | `/accounts/:account_id/payments` |


[transactions]: {{< relref "resource/transaction.md" >}}
[operations_all]: #
[operations_single]: #
[operations_for_account]: #
[operations_for_ledger]: #
[payments_for_account]: #
