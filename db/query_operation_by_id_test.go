package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestOperationByIdQuery(t *testing.T) {
	test.LoadScenario("base")
	ctx := test.Context()
	db := OpenTestDatabase()
	defer db.Close()

	Convey("OperationByIdQuery", t, func() {

		Convey("Existing record behavior", func() {
			id := int64(17179873280)
			q := OperationByIdQuery{
				SqlQuery{db},
				id,
			}
			result, err := First(ctx, q)
			So(err, ShouldBeNil)
			op := result.(OperationRecord)

			So(op.Id, ShouldEqual, id)
			So(op.TransactionId, ShouldEqual, id)
		})

		Convey("Missing record behavior", func() {
			id := int64(0)
			q := OperationByIdQuery{
				SqlQuery{db},
				id,
			}
			result, err := First(ctx, q)
			So(result, ShouldBeNil)
			So(err, ShouldBeNil)
		})

	})
}
