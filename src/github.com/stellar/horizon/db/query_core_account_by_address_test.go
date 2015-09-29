package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestCoreAccountByAddressQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("CoreAccountByAddress", t, func() {
		var account CoreAccountRecord

		Convey("Existing record behavior", func() {
			address := "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"
			q := CoreAccountByAddressQuery{
				SqlQuery{core},
				address,
			}

			err := Get(ctx, q, &account)
			So(err, ShouldBeNil)

			So(account.Accountid, ShouldEqual, address)
			So(account.Balance, ShouldEqual, 999999996999999700)
		})

		Convey("Missing record behavior", func() {
			address := "not real"
			q := CoreAccountByAddressQuery{
				SqlQuery{core},
				address,
			}
			err := Get(ctx, q, &account)
			So(err, ShouldEqual, ErrNoResults)
		})

	})
}
