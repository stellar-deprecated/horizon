---
id: page
title: Page
category: Resources
---

Pages are objects that represent a subset of objects from a larger collection.
As an example, it would be unfeasible to provide the
[All Transactions][transactions_all] endpoint without paging;  Over time there
will be millions of transactions in the Stellar network's ledger and returning
them all over a single request would be unfeasible.

## Attributes

A page itself exposes no attributes.  It is merely a container for embedded
records and some links to aid in iterating the entire collection the page is
part of.

## Embedded Resources

A page contains an embedded set of `records`, regardless of the contained
resource.

## Links

A page provides a couple of links to ease in iteration.

|      |                        Example                         |           Relation           |
| ---- | ------------------------------------------------------ | ---------------------------- |
| self | `/transactions`                                        |                              |
| prev | `/transactions?cursor=12884905984&order=desc&limit=10` | The previous page of results |
| next | `/transactions?cursor=12884905984&order=asc&limit=10`  | The next page of results     |

## Example

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
      "href": "/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments?cursor=12884905984&order=asc&limit=100"
    },
    "prev": {
      "href": "/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments?cursor=12884905984&order=desc&limit=100"
    },
    "self": {
      "href": "/account/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/payments?limit=100"
    }
  }
}

```

## Endpoints

Any endpoint that provides a collection of resources should represent them as
pages.

[transactions_all]: {{< relref "endpoint/transactions_all.md" >}}
