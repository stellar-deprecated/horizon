package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestLedgerStateQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("LedgerStateQuery", t, func() {
		var ls LedgerState

		q := LedgerStateQuery{
			SqlQuery{history},
			SqlQuery{core},
		}

		err := Get(ctx, q, &ls)
		So(err, ShouldBeNil)
		So(ls.HorizonSequence, ShouldEqual, 3)
		So(ls.StellarCoreSequence, ShouldEqual, 3)
	})
}
