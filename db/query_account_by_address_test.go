package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestAccountByAddressQuery(t *testing.T) {
	test.LoadScenario("non_native_payment")

	Convey("AccountByAddress", t, func() {
		notreal := "not_real"
		withtl := "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ"
		notl := "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC"

		q := AccountByAddressQuery{
			Core:    SqlQuery{core},
			History: SqlQuery{history},
			Address: withtl,
		}

		result, err := First(ctx, q)
		So(err, ShouldBeNil)
		So(result, ShouldNotBeNil)

		account := result.(AccountRecord)

		So(account.Address, ShouldEqual, withtl)
		So(account.Seqnum, ShouldEqual, 12884901889)
		So(len(account.Trustlines), ShouldEqual, 1)

		q.Address = notl
		result, err = First(ctx, q)
		So(err, ShouldBeNil)
		So(result, ShouldNotBeNil)

		q.Address = notreal
		result, err = First(ctx, q)
		So(err, ShouldBeNil)
		So(result, ShouldBeNil)
	})
}
