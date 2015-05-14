package db

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestLedgerStateQuery(t *testing.T) {
	test.LoadScenario("base")
	horizon := OpenTestDatabase()
	defer horizon.Close()
	core := OpenStellarCoreTestDatabase()
	defer core.Close()

	Convey("LedgerStateQuery", t, func() {

		q := LedgerStateQuery{
			SqlQuery{horizon},
			SqlQuery{core},
		}
		record, err := First(q)
		So(err, ShouldBeNil)

		ls := record.(LedgerState)
		So(ls.HorizonSequence, ShouldEqual, 4)
		So(ls.StellarCoreSequence, ShouldEqual, 4)
	})
}
