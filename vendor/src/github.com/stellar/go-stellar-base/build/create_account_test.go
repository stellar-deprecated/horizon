package build

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base"
)

func TestCreateAccountMutators(t *testing.T) {
	Convey("CreateAccountBuilder Mutators:", t, func() {
		b := CreateAccountBuilder{}

		Convey("Destination sets the destination of a payment", func() {
			address := "gLtaC2yiJs3r8YE2bTiVfFs9Mi5KdRoLNLUA45HYVy4iNd7S9p"
			aid, _ := stellarbase.AddressToAccountId(address)

			b.Mutate(Destination{address})
			So(b.CA.Destination, ShouldEqual, aid)
			So(b.Err, ShouldBeNil)
		})

		Convey("Destination sets an error for invalid addresses", func() {
			address := "foo"
			b.Mutate(Destination{address})
			So(b.Err, ShouldNotBeNil)
		})

		Convey("SourceAccount sets the transaction's SourceAccount correctly", func() {
			address := "gLtaC2yiJs3r8YE2bTiVfFs9Mi5KdRoLNLUA45HYVy4iNd7S9p"
			aid, _ := stellarbase.AddressToAccountId(address)

			b.Mutate(SourceAccount{address})
			So(b.O.SourceAccount, ShouldNotBeNil)
			So(*b.O.SourceAccount, ShouldEqual, aid)
			So(b.Err, ShouldBeNil)
		})

		Convey("SourceAccount sets an error for invalid addresses", func() {
			address := "foo"
			b.Mutate(SourceAccount{address})
			So(b.Err, ShouldNotBeNil)
		})

		Convey("NativeAmount sets starting balance correctly", func() {
			b.Mutate(NativeAmount{101})
			So(b.Err, ShouldBeNil)
			So(b.CA.StartingBalance, ShouldEqual, 101)
		})
	})
}
