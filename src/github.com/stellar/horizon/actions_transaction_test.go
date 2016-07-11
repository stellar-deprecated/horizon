package horizon

import (
	"encoding/json"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/resource"
	"github.com/stellar/horizon/test"
	"github.com/stellar/horizon/txsub"
	"github.com/stellar/horizon/txsub/sequence"
	"net/url"
	"testing"
)

func TestTransactionActions(t *testing.T) {

	Convey("Transactions Actions:", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		Convey("GET /transactions/2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d", func() {
			w := rh.Get("/transactions/2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d")
			So(w.Code, ShouldEqual, 200)

			var result resource.Transaction
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result.Hash, ShouldEqual, "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d")
		})

		Convey("GET /transactions/not_real", func() {
			w := rh.Get("/transactions/not_real")
			So(w.Code, ShouldEqual, 404)
		})

		Convey("GET /ledgers/100/transactions", func() {
			w := rh.Get("/ledgers/100/transactions")
			So(w.Code, ShouldEqual, 404)
		})

		Convey("GET /transactions", func() {
			w := rh.Get("/transactions")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 4)
		})

		Convey("GET /ledgers/:ledger_id/transactions", func() {
			w := rh.Get("/ledgers/1/transactions")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/2/transactions")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/ledgers/3/transactions")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /accounts/:account_od/transactions", func() {
			w := rh.Get("/accounts/GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H/transactions")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/transactions")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/accounts/GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU/transactions")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 2)
		})

		Convey("POST /transactions", func() {
			Convey("503 response when Sequence buffer is full", func() {
				app.submitter.Results = &txsub.MockResultProvider{
					Results: []txsub.Result{
						{Err: sequence.ErrNoMoreRoom},
					},
				}

				w := rh.Post(
					"/transactions",
					url.Values{"tx": []string{"AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAECDzqvkQBQoNAJifPRXDoLhvtycT3lFPCQ51gkdsFHaBNWw05S/VhW0Xgkr0CBPE4NaFV2Kmcs3ZwLmib4TRrML"}},
					test.RequestHelperNoop,
				)
				So(w.Code, ShouldEqual, 503)

			})

			Convey("200 response for existing transaction", func() {
				w := rh.Post(
					"/transactions",
					url.Values{"tx": []string{"AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAECDzqvkQBQoNAJifPRXDoLhvtycT3lFPCQ51gkdsFHaBNWw05S/VhW0Xgkr0CBPE4NaFV2Kmcs3ZwLmib4TRrML"}},
					test.RequestHelperNoop,
				)
				So(w.Code, ShouldEqual, 200)

			})
		})

	})
}
