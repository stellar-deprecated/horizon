package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/db/records/history"
	"github.com/stellar/horizon/test"
)

func TestOperationByIdQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("OperationByIdQuery", t, func() {
		var op history.Operation

		Convey("Existing record behavior", func() {
			id := int64(8589938689)
			q := OperationByIdQuery{
				SqlQuery{horizonDb},
				id,
			}
			err := Get(ctx, q, &op)
			So(err, ShouldBeNil)
			So(op.ID, ShouldEqual, id)
			So(op.TransactionID, ShouldEqual, id-1)
		})

		Convey("Missing record behavior", func() {
			id := int64(0)
			q := OperationByIdQuery{
				SqlQuery{horizonDb},
				id,
			}
			err := Get(ctx, q, &op)
			So(err, ShouldEqual, ErrNoResults)
		})

	})
}
