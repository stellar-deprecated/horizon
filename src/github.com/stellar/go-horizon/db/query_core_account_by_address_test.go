package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestCoreAccountByAddressQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("CoreAccountByAddress", t, func() {
		var account CoreAccountRecord

		Convey("Existing record behavior", func() {
			address := "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ"
			q := CoreAccountByAddressQuery{
				SqlQuery{core},
				address,
			}

			err := Get(ctx, q, &account)
			So(err, ShouldBeNil)

			So(account.Accountid, ShouldEqual, address)
			So(account.Balance, ShouldEqual, 99999996999999970)
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
