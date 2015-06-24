package build

import (
	"errors"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base"
)

func TestTransactionEnvelopeMutators(t *testing.T) {
	Convey("TransactionEnvelope Mutators:", t, func() {
		b := TransactionEnvelopeBuilder{}

		Convey("TransactionBuilder sets the TX of the envelope", func() {
			tx := Transaction(Sequence{10})
			b.Mutate(tx)
			So(b.E.Tx.SeqNum, ShouldEqual, 10)
			So(b.Err, ShouldBeNil)
		})

		Convey("TransactionBuilder propagates its error upwards", func() {
			tx := TransactionBuilder{Err: errors.New("busted in some fashion")}
			b.Mutate(tx)
			So(b.Err, ShouldNotBeNil)
		})

		Convey("Sign adds a signature to the envelope", func() {
			_, spriv, _ := stellarbase.GenerateKeyFromSeed("s3Fy8h5LEcYVE8aofthKWHeJpygbntw5HgcekFw93K6XqTW4gEx")

			// TODO: ensure the signatures are valid

			b.Mutate(Sign{&spriv})
			So(len(b.E.Signatures), ShouldEqual, 1)
			So(b.Err, ShouldBeNil)
			b.Mutate(Sign{&spriv})
			So(len(b.E.Signatures), ShouldEqual, 2)
			So(b.Err, ShouldBeNil)
		})

		Convey("Sign sets an error with an invalid key", func() {
			b.Mutate(Sign{nil})
			So(len(b.E.Signatures), ShouldEqual, 0)
			So(b.Err, ShouldNotBeNil)
		})
	})
}
