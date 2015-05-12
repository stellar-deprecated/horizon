package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestAccountByAddressQuery(t *testing.T) {
	test.LoadScenario("base")
	db := OpenTestDatabase()
	defer db.Close()

	Convey("AccountByAddress", t, func() {

		Convey("Existing record behavior", func() {
			address := "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC"
			q := AccountByAddressQuery{
				SqlQuery{db},
				address,
			}
			result, err := First(q)
			So(err, ShouldBeNil)
			account := result.(AccountRecord)

			So(account.Id, ShouldEqual, 0)
			So(account.Address, ShouldEqual, address)
		})

		Convey("Missing record behavior", func() {
			address := "not real"
			q := AccountByAddressQuery{
				SqlQuery{db},
				address,
			}
			result, err := First(q)
			So(result, ShouldBeNil)
			So(err, ShouldBeNil)
		})

	})
}
