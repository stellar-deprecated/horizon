package build

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

func TestTransactionMutators(t *testing.T) {
	Convey("TransactionBuilder Mutators:", t, func() {
		b := TransactionBuilder{}

		Convey("Defaults works", func() {
			b.Mutate(Defaults{})
			So(b.TX.Fee, ShouldEqual, 100)
			So(b.TX.Memo.Type, ShouldResemble, xdr.MemoTypeMemoNone)
		})

		Convey("PaymentBuilder appends its payment to the operation list", func() {
			b.Mutate(Payment())
			So(len(b.TX.Operations), ShouldEqual, 1)
		})

		Convey("SourceAccount sets the transaction's SourceAccount correctly", func() {
			address := "GAWSI2JO2CF36Z43UGMUJCDQ2IMR5B3P5TMS7XM7NUTU3JHG3YJUDQXA"
			aid, _ := stellarbase.AddressToAccountId(address)

			b.Mutate(SourceAccount{address})
			So(b.TX.SourceAccount.MustEd25519(), ShouldEqual, aid.MustEd25519())
			So(b.Err, ShouldBeNil)
		})

		Convey("SourceAccount sets an error for invalid addresses", func() {
			address := "foo"
			b.Mutate(SourceAccount{address})
			So(b.Err, ShouldNotBeNil)
		})

		Convey("Sequence sets the transaction's Sequence correctly", func() {
			b.Mutate(Sequence{1})
			So(b.TX.SeqNum, ShouldEqual, 1)
			b.Mutate(Sequence{12345})
			So(b.TX.SeqNum, ShouldEqual, 12345)
		})
	})
}
