package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestTransactionByHashQuery(t *testing.T) {

	Convey("TransactionByHashQuery", t, func() {
		test.LoadScenario("base")
		db := OpenTestDatabase()

		Convey("Existing record behavior", func() {
			hash := "b313ee4b54d033eafd6bdc9c998b6ee8dbfe814da491b9182de8b63508e31369"
			q := TransactionByHashQuery{GormQuery{&db}, hash}
			found, err := First(q)
			So(err, ShouldBeNil)
			tx := found.(TransactionRecord)
			So(tx.TransactionHash, ShouldEqual, hash)
		})

		Convey("Missing record behavior", func() {
			hash := "not_real"
			q := TransactionByHashQuery{GormQuery{&db}, hash}
			found, err := First(q)
			So(err, ShouldBeNil)
			So(found, ShouldBeNil)
		})
	})
}
