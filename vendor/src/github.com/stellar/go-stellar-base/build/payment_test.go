package build

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

func TestPaymentMutators(t *testing.T) {
	Convey("TransactionBuilder Mutators:", t, func() {
		b := PaymentBuilder{}

		Convey("Destination sets the destination of a payment", func() {
			address := "GAWSI2JO2CF36Z43UGMUJCDQ2IMR5B3P5TMS7XM7NUTU3JHG3YJUDQXA"
			aid, _ := stellarbase.AddressToAccountId(address)

			b.Mutate(Destination{address})
			So(b.P.Destination.MustEd25519(), ShouldEqual, aid.MustEd25519())
			So(b.Err, ShouldBeNil)
		})

		Convey("Destination sets an error for invalid addresses", func() {
			address := "foo"
			b.Mutate(Destination{address})
			So(b.Err, ShouldNotBeNil)
		})

		Convey("SourceAccount sets the transaction's SourceAccount correctly", func() {
			address := "GAWSI2JO2CF36Z43UGMUJCDQ2IMR5B3P5TMS7XM7NUTU3JHG3YJUDQXA"
			aid, _ := stellarbase.AddressToAccountId(address)

			b.Mutate(SourceAccount{address})
			So(b.O.SourceAccount, ShouldNotBeNil)
			So(b.O.SourceAccount.MustEd25519(), ShouldEqual, aid.MustEd25519())
			So(b.Err, ShouldBeNil)
		})

		Convey("SourceAccount sets an error for invalid addresses", func() {
			address := "foo"
			b.Mutate(SourceAccount{address})
			So(b.Err, ShouldNotBeNil)
		})

		Convey("NativeAmount sets amount and currency correctly", func() {
			b.Mutate(NativeAmount{101})
			So(b.Err, ShouldBeNil)

			So(b.P.Asset.Type, ShouldResemble, xdr.AssetTypeAssetTypeNative)
			So(b.P.Amount, ShouldEqual, 101)
		})
	})
}
