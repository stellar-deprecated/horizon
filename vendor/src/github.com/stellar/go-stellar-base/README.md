# Go Stellar Base
[![Build Status](https://travis-ci.org/stellar/go-stellar-base.svg?branch=master)](https://travis-ci.org/stellar/go-stellar-base)

*STATUS:  This library is currently in alpha testing.  It has support reading/writing xdr, and can sign and hash byte slices in accordance with the stellar protocol, but does not yet have the necessary helpers to make constructing valid transactions easy.*

The stellar-base library is the lowest-level stellar helper library.  It consists of classes
to read, write, hash, and sign the xdr structures that are used in stellar-core.

## Installation


```shell
go get github.com/stellar/go-stellar-base
```

## Usage

Let's first decode a transaction (taken from stellar-core's `txhistory` table):

```go
func ExampleDecodeTransaction() {
	data := "rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAEAAAAAAAA" +
		"AAAAAAAEAAAAAAAAAAW5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAA" +
		"AAAAAC+vCAAAAAAa6jei0gQGmrUfm+o2CMv/w32YzJgGYlmgG6CUW3FwyD6AZ/5TtPZ" +
		"qEt9kyC3GJeXfzoS667ZPhPUSNjSWgAeDPHFLcM"

	rawr := strings.NewReader(data)
	b64r := base64.NewDecoder(base64.StdEncoding, rawr)

	var tx xdr.TransactionEnvelope
	bytesRead, err := xdr.Unmarshal(b64r, &tx)

	fmt.Printf("read %d bytes\n", bytesRead)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("This tx has %d operations\n", len(tx.Tx.Operations))
	// Output: read 180 bytes
	// This tx has 1 operations
}
```

Now, the low-level creation of a TransactionEnvelope:

```go
// ExampleLowLevelTransaction creates and signs a simple transaction, and then
// encodes it into a hex string capable of being submitted to stellar-core.
//
// It uses the low-level xdr facilities to create the transaction.
func ExampleLowLevelTransaction() {
	spub, spriv, err := GenerateKeyFromSeed("s3Fy8h5LEcYVE8aofthKWHeJpygbntw5HgcekFw93K6XqTW4gEx")

	if err != nil {
		log.Fatal(err)
	}

	dpub, _, err := GenerateKeyFromSeed("sfkPCKA6XgaeHZH3NE57i3QrjVcw61c1noWQCgnHa6KJP2BrbXD")

	if err != nil {
		log.Fatal(err)
	}

	op := xdr.PaymentOp{
		Destination: dpub.KeyData(),
		Currency:    xdr.NewCurrencyCurrencyTypeNative(),
		Amount:      50 * 10000000,
	}

	tx := xdr.Transaction{
		SourceAccount: spub.KeyData(),
		Fee:           10,
		SeqNum:        xdr.SequenceNumber(1),
		Memo:          xdr.NewMemoMemoNone(),
		Operations: []xdr.Operation{
			{Body: xdr.NewOperationBodyPayment(op)},
		},
	}

	var txBytes bytes.Buffer
	_, err = xdr.Marshal(&txBytes, tx)
	if err != nil {
		log.Fatal(err)
	}

	txHash := Hash(txBytes.Bytes())
	signature := spriv.Sign(txHash[:])

	ds := xdr.DecoratedSignature{
		Hint:      spriv.Hint(),
		Signature: xdr.Uint512(signature),
	}

	txe := xdr.TransactionEnvelope{
		Tx:         tx,
		Signatures: []xdr.DecoratedSignature{ds},
	}

	var txeBytes bytes.Buffer
	_, err = xdr.Marshal(&txeBytes, txe)
	if err != nil {
		log.Fatal(err)
	}

	txeHex := hex.EncodeToString(txeBytes.Bytes())

	fmt.Printf("tx hex: %s", txeHex)
	// Output: tx hex: 3658fe7598d20c7a6de3297f84bc52bd2a1ec8c0f1f6c5b41cc1c7571b4331f00000000a000000000000000100000000000000000000000100000000000000012d24692ed08bbf679ba199448870d2191e876fecd92fdd9f6d274da4e6de134100000000000000001dcd650000000001dd302d0c0cee527cf02f6a0aec6916966298712914c63e3c57de74a6e27c29ea234a555fcc36533417afe4e1147815a42529fbca3429bc7caf0a06dc6b383ca6e9d4d80f
}


```

## Contributing

Please [see CONTRIBUTING.md for details](CONTRIBUTING.md).
