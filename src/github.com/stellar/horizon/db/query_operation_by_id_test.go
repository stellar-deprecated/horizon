package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestOperationByIdQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("OperationByIdQuery", t, func() {
		var op OperationRecord

		Convey("Existing record behavior", func() {
			id := int64(8589938689)
			q := OperationByIdQuery{
				SqlQuery{historyDb},
				id,
			}
			err := Get(ctx, q, &op)
			So(err, ShouldBeNil)
			So(op.Id, ShouldEqual, id)
			So(op.TransactionId, ShouldEqual, id-1)
		})

		Convey("Missing record behavior", func() {
			id := int64(0)
			q := OperationByIdQuery{
				SqlQuery{historyDb},
				id,
			}
			err := Get(ctx, q, &op)
			So(err, ShouldEqual, ErrNoResults)
		})

	})
}
