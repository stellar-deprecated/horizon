package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestHistoryAccountByAddressQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("AccountByAddress", t, func() {
		var account HistoryAccountRecord

		Convey("Existing record behavior", func() {
			address := "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"
			q := HistoryAccountByAddressQuery{
				SqlQuery{historyDb},
				address,
			}
			err := Get(ctx, q, &account)
			So(err, ShouldBeNil)
			So(account.Id, ShouldEqual, 1)
			So(account.Address, ShouldEqual, address)
		})

		Convey("Missing record behavior", func() {
			address := "not real"
			q := HistoryAccountByAddressQuery{
				SqlQuery{historyDb},
				address,
			}
			err := Get(ctx, q, &account)
			So(err, ShouldEqual, ErrNoResults)
		})

	})
}
