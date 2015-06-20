package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestOperationByIdQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("OperationByIdQuery", t, func() {
		var op OperationRecord

		Convey("Existing record behavior", func() {
			id := int64(17179873280)
			q := OperationByIdQuery{
				SqlQuery{history},
				id,
			}
			err := Get(ctx, q, &op)
			So(err, ShouldBeNil)
			So(op.Id, ShouldEqual, id)
			So(op.TransactionId, ShouldEqual, id)
		})

		Convey("Missing record behavior", func() {
			id := int64(0)
			q := OperationByIdQuery{
				SqlQuery{history},
				id,
			}
			err := Get(ctx, q, &op)
			So(err, ShouldEqual, ErrNoResults)
		})

	})
}
