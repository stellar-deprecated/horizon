package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestTransactionByHashQuery(t *testing.T) {

	Convey("TransactionByHashQuery", t, func() {
		test.LoadScenario("base")

		var record TransactionRecord

		Convey("Existing record behavior", func() {
			hash := "99fd775e6eed3e331c7df84b540d955db4ece9f57d22980715918acb7ce5bbf4"
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
