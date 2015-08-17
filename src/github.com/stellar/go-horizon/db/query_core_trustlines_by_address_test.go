package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestCoreTrustlinesByAddressQuery(t *testing.T) {
	test.LoadScenario("non_native_payment")

	Convey("CoreTrustlinesByAddress", t, func() {
		var tls []CoreTrustlineRecord

		withtl := "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON"
		notl := "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ"

		q := CoreTrustlinesByAddressQuery{
			SqlQuery{core},
			withtl,
		}

		err := Select(ctx, q, &tls)
		So(err, ShouldBeNil)
		So(len(tls), ShouldEqual, 1)

		tl := tls[0]

		So(tl.Accountid, ShouldEqual, withtl)
		So(tl.Issuer, ShouldEqual, "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4")
		So(tl.Balance, ShouldEqual, 500000000)
		So(tl.Tlimit, ShouldEqual, 9223372036854775807)
		So(tl.Assetcode, ShouldEqual, "USD")

		q = CoreTrustlinesByAddressQuery{
			SqlQuery{core},
			notl,
		}

		err = Select(ctx, q, &tls)
		So(err, ShouldBeNil)
		t.Log(tls)
		So(len(tls), ShouldEqual, 0)
	})
}
