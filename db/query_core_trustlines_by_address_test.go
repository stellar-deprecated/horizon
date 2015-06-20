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

		withtl := "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ"
		notl := "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC"

		q := CoreTrustlinesByAddressQuery{
			SqlQuery{core},
			withtl,
		}

		err := Select(ctx, q, &tls)
		So(err, ShouldBeNil)
		So(len(tls), ShouldEqual, 1)

		tl := tls[0]

		So(tl.Accountid, ShouldEqual, withtl)
		So(tl.Issuer, ShouldEqual, "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq")
		So(tl.Balance, ShouldEqual, 500000000)
		So(tl.Tlimit, ShouldEqual, 9223372036854775807)
		So(tl.Alphanumcurrency, ShouldEqual, "USD")

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
