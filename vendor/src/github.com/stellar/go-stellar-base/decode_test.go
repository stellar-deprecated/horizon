package stellarbase

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"log"
	"strings"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	xdr "github.com/stellar/go-stellar-base/xdr"
)

func TestDecode(t *testing.T) {
	Convey("Decode XDR Enum", t, func() {
		// works for positive values
		var op xdr.OperationType
		r := bytes.NewReader([]byte{0x00, 0x00, 0x00, 0x00})
		xdr.Unmarshal(r, &op)
		So(op, ShouldEqual, xdr.OperationTypeCreateAccount)

		r = bytes.NewReader([]byte{0x00, 0x00, 0x00, 0x08})
		xdr.Unmarshal(r, &op)
		So(op, ShouldEqual, xdr.OperationTypeAccountMerge)

		// works for negative values
		var trc xdr.TransactionResultCode
		r = bytes.NewReader([]byte{0xFF, 0xFF, 0xFF, 0xFF})
		xdr.Unmarshal(r, &trc)
		So(trc, ShouldEqual, xdr.TransactionResultCodeTxFailed)

		r = bytes.NewReader([]byte{0x00, 0xFF, 0xFF, 0xFF})
		_, err := xdr.Unmarshal(r, &op)
		So(err, ShouldNotBeNil)
	})

	Convey("Decodes Memo", t, func() {
		data := "AAAAAA=="
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var memo xdr.Memo

		_, err := xdr.Unmarshal(b64r, &memo)

		So(err, ShouldBeNil)
	})

	Convey("Decodes AccountID", t, func() {
		data := "AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5M"
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var id xdr.AccountId
		_, err := xdr.Unmarshal(b64r, &id)

		So(err, ShouldBeNil)
	})

	Convey("Decodes OperationBody", t, func() {
		data := "AAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msoA"
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var body xdr.OperationBody
		_, err := xdr.Unmarshal(b64r, &body)

		So(err, ShouldBeNil)
	})

	Convey("Decode TransactionResultPair", t, func() {
		data := "mf13Xm7tPjMcffhLVA2VXbTs6fV9IpgHFZGKy3zlu/QAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA=="
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var trp xdr.TransactionResultPair
		_, err := xdr.Unmarshal(b64r, &trp)

		So(err, ShouldBeNil)
		So(len(trp.TransactionHash), ShouldEqual, 32)
		So(trp.Result.FeeCharged, ShouldEqual, 10)

		trr := trp.Result.Result
		So(trr.Code, ShouldEqual, xdr.TransactionResultCodeTxSuccess)

		So(trr.Results, ShouldNotBeNil)

		r := trr.MustResults()
		So(len(r), ShouldEqual, 1)

		opr := r[0]
		So(opr.Code, ShouldEqual, xdr.OperationResultCodeOpInner)

		oprr := opr.MustTr()
		So(oprr.Type, ShouldEqual, xdr.OperationTypeCreateAccount)

		cr := oprr.MustCreateAccountResult()
		So(cr.Code, ShouldEqual, xdr.CreateAccountResultCodeCreateAccountSuccess)

		So(func() {
			oprr.MustAccountMergeResult()
		}, ShouldPanic)
	})

	Convey("Decode TransactionEnvelope", t, func() {
		data := "AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEAKZ7IPj/46PuWU6ZOtyMosctNAkXRNX9WCAI5RnfRk+AyxDLoDZP/9l3NvsxQtWj9juQOuoBlFLnWu8intgxQA"
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var txe xdr.TransactionEnvelope
		_, err := xdr.Unmarshal(b64r, &txe)

		So(err, ShouldBeNil)
		So(len(txe.Signatures), ShouldEqual, 1)

		tx := txe.Tx

		So(tx.Fee, ShouldEqual, 10)
		So(tx.SeqNum, ShouldEqual, 1)

		So(tx.Memo.Type, ShouldEqual, xdr.MemoTypeMemoNone)

		op := tx.Operations[0]

		So(op.SourceAccount, ShouldBeNil)

		p := op.Body.MustCreateAccountOp()
		So(p.StartingBalance, ShouldEqual, 1000000000)
	})

	Convey("Decode TransactionMeta", t, func() {
		data := "AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V4XYn/9gAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wFjRXgh7zX2AAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA=="
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var m xdr.TransactionMeta
		_, err := xdr.Unmarshal(b64r, &m)

		So(err, ShouldBeNil)
		op := m.MustOperations()
		So(len(op), ShouldEqual, 1)
		So(len(op[0].Changes), ShouldEqual, 1)
	})

	Convey("Roundtrip TransactionEnvelope", t, func() {
		data := "AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEAKZ7IPj/46PuWU6ZOtyMosctNAkXRNX9WCAI5RnfRk+AyxDLoDZP/9l3NvsxQtWj9juQOuoBlFLnWu8intgxQA"
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var txe xdr.TransactionEnvelope
		n, err := xdr.Unmarshal(b64r, &txe)
		So(err, ShouldBeNil)

		var output bytes.Buffer
		b64w := base64.NewEncoder(base64.StdEncoding, &output)

		n2, err := xdr.Marshal(b64w, txe)

		So(n2, ShouldEqual, n)
		So(output.String(), ShouldEqual, data)
	})
}

func ExampleDecodeTransaction() {
	data := "AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEAKZ7IPj/46PuWU6ZOtyMosctNAkXRNX9WCAI5RnfRk+AyxDLoDZP/9l3NvsxQtWj9juQOuoBlFLnWu8intgxQA"

	rawr := strings.NewReader(data)
	b64r := base64.NewDecoder(base64.StdEncoding, rawr)

	var tx xdr.TransactionEnvelope
	bytesRead, err := xdr.Unmarshal(b64r, &tx)

	fmt.Printf("read %d bytes\n", bytesRead)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("This tx has %d operations\n", len(tx.Tx.Operations))
	// Output: read 192 bytes
	// This tx has 1 operations
}
