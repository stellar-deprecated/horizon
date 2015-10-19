---
title: Find Payment Paths
category: Endpoints
---

The Stellar Network allows payments to be made across currencies through path payments.  A path payment specifies a series of currencies to route a payment through, from source asset (the asset debited from the payer) to destination asset (the asset credited to the payee).

The path search is specified using:

- The destination address
- The source address
- The currency and amount that the destination account should receive


## Request

```
GET /paths?destination_account={da}&source_account={sa}&destination_asset_type={at}&destination_asset_code={ac}&destination_asset_issuer={di}&destination_amount={amount}
```

## Arguments

| name                        | notes  | description | example                                                    |
|-----------------------------|--------|-------------|------------------------------------------------------------|
| `?destination_account`      | string |             | `GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V` |
| `?destination_asset_type`   | string |             | `credit_alphanum4`                                         |
| `?destination_asset_code`   | string |             | `GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V` |
| `?destination_asset_issuer` | string |             | `GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V` |
| `?destination_amount`       | string |             | `10.1`                                                     |
| `?source_account`           | string |             | `GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP` |



### curl Example Request

```sh
curl https://horizon-testnet.stellar.org/paths?destination_account=GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V&source_account=GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP&destination_asset_type=credit_alphanum4&destination_asset_code=EUR&destination_asset_issuer=GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN&destination_amount=20
```

## Response

This endpoint responds with a single Transaction.  See [transaction resource](./resources/transaction.md) for reference.

### Example Response:

```json
{
    "_embedded": {
        "records": [
            {
                "destination_amount": "20.0000000",
                "destination_asset_code": "EUR",
                "destination_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                "destination_asset_type": "credit_alphanum4",
                "path": [],
                "source_amount": "30.0000000",
                "source_asset_code": "USD",
                "source_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                "source_asset_type": "credit_alphanum4"
            },
            {
                "destination_amount": "20.0000000",
                "destination_asset_code": "EUR",
                "destination_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                "destination_asset_type": "credit_alphanum4",
                "path": [
                    {
                        "asset_code": "1",
                        "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                        "asset_type": "credit_alphanum4"
                    }
                ],
                "source_amount": "20.0000000",
                "source_asset_code": "USD",
                "source_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                "source_asset_type": "credit_alphanum4"
            },
            {
                "destination_amount": "20.0000000",
                "destination_asset_code": "EUR",
                "destination_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                "destination_asset_type": "credit_alphanum4",
                "path": [
                    {
                        "asset_code": "21",
                        "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                        "asset_type": "credit_alphanum4"
                    },
                    {
                        "asset_code": "22",
                        "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                        "asset_type": "credit_alphanum4"
                    }
                ],
                "source_amount": "20.0000000",
                "source_asset_code": "USD",
                "source_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
                "source_asset_type": "credit_alphanum4"
            }        ]
    },
    "_links": {
        "self": {
            "href": "/paths"
        }
    }
}
```

## Possible Errors

- The [standard errors](../learn/errors.md#Standard_Errors).
- [not_found](./errors/not-found.md): A `not_found` error will be returned if no paths could be found to fulfill this payment request
