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
			hash := "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d"
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
