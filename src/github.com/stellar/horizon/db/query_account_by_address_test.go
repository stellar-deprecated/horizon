package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/db/records"
	"github.com/stellar/horizon/test"
)

func TestAccountByAddressQuery(t *testing.T) {
	test.LoadScenario("non_native_payment")

	Convey("AccountByAddress", t, func() {
		var account records.Account

		notreal := "not_real"
		withtl := "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON"
		notl := "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"

		q := AccountByAddressQuery{
			Core:    SqlQuery{coreDb},
			History: SqlQuery{horizonDb},
			Address: withtl,
		}

		err := Get(ctx, q, &account)
		So(err, ShouldBeNil)

		So(account.History.Address, ShouldEqual, withtl)
		So(account.Seqnum, ShouldEqual, "8589934593")
		So(len(account.Trustlines), ShouldEqual, 1)

		q.Address = notl
		err = Get(ctx, q, &account)
		So(err, ShouldBeNil)
		So(len(account.Trustlines), ShouldEqual, 0)

		q.Address = notreal
		err = Get(ctx, q, &account)
		So(err, ShouldEqual, ErrNoResults)
	})
}
