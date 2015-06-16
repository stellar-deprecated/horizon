---
id: transactions_create
title: Post Transaction
category: Endpoints
---

Posts a new transaction to the Stellar Network.  Note that creating a valid
transactions and signing it properly should be the responsibility of your
[client library](#).

Also note, this endpoint is presently a very thin wrapper around the raw
transaction submission endpoint in stellar-core.  This endpoint will probably
change quite soon to reflect more of the design choices made by the rest of
horizon

## Request

```
POST /transactions
```

### Arguments

| name | loc  |  notes   |                                                                                                                                                                                                                 example                                                                                                                                                                                                                  | description |
| ---- | ---- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `tx` | body | required | 899b2840ed5636c56ddc5f14b23975f79f1ba2388d2694e4c56ecdddc960e5ef<br>0000000a000000000000000100000000ffffffff000000010000000000000000<br>500e14fe9d7dc549e30244da424cfbcabe2166a55237897473d3f7358a086b48<br>00000000000009184e72a000000000000000000000000000000009184e72a000<br>00000001899b28402e992cc5fc6d7e0f888b7afa173a35d3ce87526bc37d8171<br>e2d9ee7f2715d1d4146a9026b13396ab8e7392f947caba1b00d398801b4644ae<br>5238f96f96ec7605 |             |


### Example

```
curl https://horizon-testnet.stellar.org/transactions \
  -X POST \
  -F "tx=899b2840ed5636c56ddc5f14b23975f79f1ba2388d2694e4c56ecdddc960e5ef0000000a000000000000000100000000ffffffff000000010000000000000000500e14fe9d7dc549e30244da424cfbcabe2166a55237897473d3f7358a086b4800000000000009184e72a000000000000000000000000000000009184e72a00000000001899b28402e992cc5fc6d7e0f888b7afa173a35d3ce87526bc37d8171e2d9ee7f2715d1d4146a9026b13396ab8e7392f947caba1b00d398801b4644ae5238f96f96ec7605"
```

## Response

This endpoint returns a resource that represents the result of initial
submission of the provided transaction to stellar-core.

### Attributes

|         Name        |  Type  |                                                               |
| ------------------- | ------ | ------------------------------------------------------------- |
| `hash`              | string | A hex-encoded hash of the submitted transaction.              |
| `result`            | string | Distilled summary of the result.  See "Result" section below. |
| `submission_result` | string | A hex-encoded `TransactionResult` XDR object.                 |

### Result

The `result` attribute of a response from this endpoint can be one of the following values:

|      `result`     |                                                                                                                            |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------- |
| malformed         | The transaction was suffiently malformed that we could not interpet it.                                                    |
| already_finished  | The hash for this transaction hash is either in the history database or is in the stellar core database.                   |
| received          | The transaction was submitted and received by stellar core, and will be included in consideration for a validared ledger   |
| failed            | The submission to stellar core failed, and was not recieved by the network.  Refer to the `submission_result` for details. |
| connection_failed | Horizon could not connect to stellar core.                                                                                 |


### Example

```
{
  "hash": "802da5683737972e5a0a6d8d4960bb43a7be64a1dbc00549eeb31729f94c75f2",
  "result": "failed",
  "submission_result": "0000000000000000fffffffb"
}
```

### Problems

This endpoint should only respond with [standard errors][se].
