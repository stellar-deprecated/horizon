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

	Convey("Decode TransactionResultPair", t, func() {
		data := "W9EizvB5Q+UMEAJR9w3y+/xvR14aO27zXb/yoQod9L8AAAAAAAAACgAAAAAAAAABAAAAAAAAAAEAAAAA"
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
		So(oprr.Type, ShouldEqual, xdr.OperationTypePayment)

		pr := oprr.MustPaymentResult()
		So(pr.Code, ShouldEqual, xdr.PaymentResultCodePaymentSuccess)

		So(func() {
			oprr.MustAccountMergeResult()
		}, ShouldPanic)
	})

	Convey("Decode TransactionEnvelope", t, func() {
		data := "rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAW5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAAAAAAAC+vCAAAAAAa6jei0gQGmrUfm+o2CMv/w32YzJgGYlmgG6CUW3FwyD6AZ/5TtPZqEt9kyC3GJeXfzoS667ZPhPUSNjSWgAeDPHFLcM"
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var txe xdr.TransactionEnvelope
		_, err := xdr.Unmarshal(b64r, &txe)

		So(err, ShouldBeNil)
		So(len(txe.Signatures), ShouldEqual, 1)

		tx := txe.Tx

		So(tx.Fee, ShouldEqual, 10)
		So(tx.SeqNum, ShouldEqual, 12884901889)

		So(tx.Memo.Type, ShouldEqual, xdr.MemoTypeMemoNone)

		op := tx.Operations[0]

		So(op.SourceAccount, ShouldBeNil)

		p := op.Body.MustPaymentOp()
		So(p.Currency.Type, ShouldEqual, xdr.CurrencyTypeCurrencyTypeNative)
		So(p.Amount, ShouldEqual, 50000000)
	})

	Convey("Decode TransactionMeta", t, func() {
		data := "AAAAAgAAAAEAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAAPpW6gAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA4n9l2AAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA="
		rawr := strings.NewReader(data)
		b64r := base64.NewDecoder(base64.StdEncoding, rawr)

		var m xdr.TransactionMeta
		_, err := xdr.Unmarshal(b64r, &m)

		So(err, ShouldBeNil)
		So(len(m.Changes), ShouldEqual, 2)
		m.Changes[0].MustUpdated()
		m.Changes[1].MustUpdated()
	})

	Convey("Roundtrip TransactionEnvelope", t, func() {
		data := "rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAW5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAAAAAAAC+vCAAAAAAa6jei0gQGmrUfm+o2CMv/w32YzJgGYlmgG6CUW3FwyD6AZ/5TtPZqEt9kyC3GJeXfzoS667ZPhPUSNjSWgAeDPHFLcM"
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
