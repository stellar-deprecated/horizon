package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestLedgerState(t *testing.T) {
	test.LoadScenario("base")
	horizon := OpenTestDatabase()
	defer horizon.Close()
	core := OpenStellarCoreTestDatabase()
	defer core.Close()

	Convey("db.UpdateLedgerState", t, func() {
		So(horizonLedgerGauge.Value(), ShouldEqual, 0)
		So(stellarCoreLedgerGauge.Value(), ShouldEqual, 0)

		UpdateLedgerState(test.Context(), SqlQuery{horizon}, SqlQuery{core})

		So(horizonLedgerGauge.Value(), ShouldEqual, 4)
		So(stellarCoreLedgerGauge.Value(), ShouldEqual, 4)
	})
}
