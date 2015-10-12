package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestPathActions(t *testing.T) {
	test.LoadScenario("paths")
	app := NewTestApp()
	defer app.Close()
	rh := NewRequestHelper(app)

	Convey("Path Actions:", t, func() {
		Convey("(no query args): GET /paths", func() {
			w := rh.Get("/paths", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
		})

		Convey("(happy path): GET /paths?{all args}", func() {
			qs := "?destination_account=GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V" +
				"&source_account=GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP" +
				"&destination_asset_type=credit_alphanum4" +
				"&destination_asset_code=EUR" +
				"&destination_asset_issuer=GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN" +
				"&destination_amount=10"

			w := rh.Get("/paths"+qs, test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			t.Log(qs)
			t.Log(w.Body.String())
			So(w.Body, ShouldBePageOf, 3)
		})
	})
}
