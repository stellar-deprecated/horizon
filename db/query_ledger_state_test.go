package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestLedgerStateQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("LedgerStateQuery", t, func() {

		q := LedgerStateQuery{
			SqlQuery{history},
			SqlQuery{core},
		}
		record, err := First(ctx, q)
		So(err, ShouldBeNil)

		ls := record.(LedgerState)
		So(ls.HorizonSequence, ShouldEqual, 4)
		So(ls.StellarCoreSequence, ShouldEqual, 4)
	})
}
