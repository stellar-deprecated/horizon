package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestTransactionByHashQuery(t *testing.T) {

	Convey("TransactionByHashQuery", t, func() {
		test.LoadScenario("base")

		var record TransactionRecord

		Convey("Existing record behavior", func() {
			hash := "c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74"
			q := TransactionByHashQuery{SqlQuery{history}, hash}
			err := Get(ctx, q, &record)
			So(err, ShouldBeNil)
			So(record.TransactionHash, ShouldEqual, hash)
		})

		Convey("Missing record behavior", func() {
			hash := "not_real"
			q := TransactionByHashQuery{SqlQuery{history}, hash}
			err := Get(ctx, q, &record)
			So(err, ShouldEqual, ErrNoResults)
		})
	})
}
