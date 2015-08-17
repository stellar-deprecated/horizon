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
		var account AccountRecord

		notreal := "not_real"
		withtl := "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON"
		notl := "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ"

		q := AccountByAddressQuery{
			Core:    SqlQuery{core},
			History: SqlQuery{history},
			Address: withtl,
		}

		err := Get(ctx, q, &account)
		So(err, ShouldBeNil)

		So(account.Address, ShouldEqual, withtl)
		So(account.Seqnum, ShouldEqual, 8589934593)
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
