package stellarbase

import (
	"bytes"
	"encoding/base64"
	"fmt"

	"github.com/stellar/go-stellar-base/xdr"
)

// ExampleLowLevelTransaction creates and signs a simple transaction, and then
// encodes it into a hex string capable of being submitted to stellar-core.
//
// It uses the low-level xdr facilities to create the transaction.
func ExampleLowLevelTransaction() {
	spub, spriv, err := GenerateKeyFromSeed("SA26PHIKZM6CXDGR472SSGUQQRYXM6S437ZNHZGRM6QA4FOPLLLFRGDX")

	if err != nil {
		panic(err)
	}

	dpub, _, err := GenerateKeyFromSeed("SBQHO2IMYKXAYJFCWGXC7YKLJD2EGDPSK3IUDHVJ6OOTTKLSCK6Z6POM")

	if err != nil {
		panic(err)
	}

	asset, err := xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)
	if err != nil {
		panic(err)
	}

	destination, err := AddressToAccountId(dpub.Address())
	if err != nil {
		panic(err)
	}

	op := xdr.PaymentOp{
		Destination: destination,
		Asset:       asset,
		Amount:      50 * 10000000,
	}

	memo, err := xdr.NewMemo(xdr.MemoTypeMemoNone, nil)

	source, err := AddressToAccountId(spub.Address())
	if err != nil {
		panic(err)
	}

	body, err := xdr.NewOperationBody(xdr.OperationTypePayment, op)
	if err != nil {
		panic(err)
	}

	tx := xdr.Transaction{
		SourceAccount: source,
		Fee:           10,
		SeqNum:        xdr.SequenceNumber(1),
		Memo:          memo,
		Operations: []xdr.Operation{
			{Body: body},
		},
	}

	var txBytes bytes.Buffer
	_, err = xdr.Marshal(&txBytes, tx)
	if err != nil {
		panic(err)
	}

	txHash := Hash(txBytes.Bytes())
	signature := spriv.Sign(txHash[:])

	ds := xdr.DecoratedSignature{
		Hint:      spriv.Hint(),
		Signature: xdr.Signature(signature[:]),
	}

	txe := xdr.TransactionEnvelope{
		Tx:         tx,
		Signatures: []xdr.DecoratedSignature{ds},
	}

	var txeBytes bytes.Buffer
	_, err = xdr.Marshal(&txeBytes, txe)
	if err != nil {
		panic(err)
	}
	txeB64 := base64.StdEncoding.EncodeToString(txeBytes.Bytes())

	fmt.Printf("tx base64: %s", txeB64)
	// Output: tx base64: AAAAAAU08yUQ8sHqhY8j9mXWwERfHC/3cKFSe/spAr0rGtO2AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAA+fnTe7/v4whpBUx96oj92jfZPz7S00l3O2xeyeqWIA0AAAAAAAAAAB3NZQAAAAAAAAAAASsa07YAAABAieruUIGcQH6RlQ+prYflPFU3nED2NvWhtaC+tgnKsqgiKURK4xo/W7EgH0+I6aQok52awbE+ksOxEQ5MLJ9eAw==
}
