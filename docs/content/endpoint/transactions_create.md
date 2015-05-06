+++
date  = "2015-05-04T14:52:29-07:00"
draft = false
title = "Post Transaction"
+++

Posts a new transaction to the Stellar Network.

## Request

```
POST /transactions
```

### Arguments

|  name  |  type  |           description           |                             example                              |
| ------ | ------ | ------------------------------- | ---------------------------------------------------------------- |
| `hash` | string | A transaction hash, hex-encoded | 6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a |

### Example

```
curl https://horizon-testnet.stellar.org/transactions \
  -X POST \
  -F "tx=899b2840ed5636c56ddc5f14b23975f79f1ba2388d2694e4c56ecdddc960e5ef0000000a000000000000000100000000ffffffff000000010000000000000000500e14fe9d7dc549e30244da424cfbcabe2166a55237897473d3f7358a086b4800000000000009184e72a000000000000000000000000000000009184e72a00000000001899b28402e992cc5fc6d7e0f888b7afa173a35d3ce87526bc37d8171e2d9ee7f2715d1d4146a9026b13396ab8e7392f947caba1b00d398801b4644ae5238f96f96ec7605"
```

## Response

### Example

### Problems


