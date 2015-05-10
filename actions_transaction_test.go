package horizon

import (
	"encoding/json"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestTransactionActions(t *testing.T) {

	Convey("Transactions Actions:", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		defer app.Cancel()
		rh := NewRequestHelper(app)

		Convey("GET /transactions/b313ee4b54d033eafd6bdc9c998b6ee8dbfe814da491b9182de8b63508e31369", func() {
			w := rh.Get("/transactions/b313ee4b54d033eafd6bdc9c998b6ee8dbfe814da491b9182de8b63508e31369", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)

			var result TransactionResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result.Hash, ShouldEqual, "b313ee4b54d033eafd6bdc9c998b6ee8dbfe814da491b9182de8b63508e31369")
		})

		Convey("GET /transactions/not_real", func() {
			w := rh.Get("/transactions/not_real", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 404)
		})

	})
}
