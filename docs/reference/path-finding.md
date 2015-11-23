---
title: Find Payment Paths
category: Endpoints
---

The Stellar Network allows payments to be made across assets through _path payments_.  A path payment specifies a series of assets to route a payment through, from source asset (the asset debited from the payer) to destination asset (the asset credited to the payee).

A path search is specified using:

- The destination address
- The source address
- The asset and amount that the destination account should receive

As part of the search, horizon will load a list of assets available to the source address and will find any payment paths from those source assets to the desired destination asset. The search's amount parameter will be used to determine if there a given path can satisfy a payment of the desired amount.

## Request

```
GET /paths?destination_account={da}&source_account={sa}&destination_asset_type={at}&destination_asset_code={ac}&destination_asset_issuer={di}&destination_amount={amount}
```

## Arguments

| name                        | notes  | description                                                                                        | example                                                    |
|-----------------------------|--------|----------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| `?destination_account`      | string | The destination address that any returned path should use                                          | `GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V` |
| `?destination_asset_type`   | string | The type of the destination asset                                                                  | `credit_alphanum4`                                         |
| `?destination_asset_code`   | string | The code for the destination, if destination_asset_type is not "native"                            | `GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V` |
| `?destination_asset_issuer` | string | The issuer for the destination, if destination_asset_type is not "native"                          | `GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V` |
| `?destination_amount`       | string | The amount, denominated in the destination asset, that any returned path should be able to satisfy | `10.1`                                                     |
| `?source_account`           | string | The sender's address.  Any returned path must use a source that the sender can hold                | `GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP` |



### curl Example Request

```sh
curl "https://horizon-testnet.stellar.org/paths?destination_account=GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V&source_account=GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP&destination_asset_type=credit_alphanum4&destination_asset_code=EUR&destination_asset_issuer=GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN&destination_amount=20"
```

## Response

This endpoint responds with a page of path resources.  See [path resource](./resources/path.md) for reference.

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
