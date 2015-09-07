package problem

import (
	"errors"
	"net/http/httptest"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/context/requestid"
	"golang.org/x/net/context"
)

func TestProblemPackage(t *testing.T) {
	b := context.Background()
	testRender := func(ctx context.Context, p interface{}) *httptest.ResponseRecorder {
		w := httptest.NewRecorder()
		Render(ctx, w, p)
		return w
	}

	Convey("Common Problems", t, func() {
		Convey("NotFound", func() {
			w := testRender(b, NotFound)
			So(w.Code, ShouldEqual, 404)
			t.Log(w.Body.String())
		})

		Convey("ServerError", func() {
			w := testRender(b, ServerError)
			So(w.Code, ShouldEqual, 500)
			t.Log(w.Body.String())
		})

		Convey("RateLimitExceeded", func() {
			w := testRender(b, RateLimitExceeded)
			So(w.Code, ShouldEqual, 429)
			t.Log(w.Body.String())
		})
	})

	Convey("problem.Inflate", t, func() {
		Convey("sets Instance to the request id based upon the context", func() {
			ctx := requestid.Context(b, "2")
			p := P{}
			Inflate(ctx, &p)

			So(p.Instance, ShouldEqual, "2")

			// when no request id is set, instance should be ""
			Inflate(b, &p)
			So(p.Instance, ShouldEqual, "")
		})
	})

	Convey("problem.Render", t, func() {
		Convey("renders the type correctly", func() {
			w := testRender(b, P{Type: "foo"})
			So(w.Body.String(), ShouldContainSubstring, "foo")
		})

		Convey("renders the status correctly", func() {
			w := testRender(b, P{Status: 201})
			So(w.Body.String(), ShouldContainSubstring, "201")
			So(w.Code, ShouldEqual, 201)
		})

		Convey("renders the extras correctly", func() {
			w := testRender(b, P{
				Extras: map[string]interface{}{"hello": "stellar"},
			})
			So(w.Body.String(), ShouldContainSubstring, "hello")
			So(w.Body.String(), ShouldContainSubstring, "stellar")
		})

		Convey("panics if non-compliant `p` is used", func() {
			So(func() { testRender(b, nil) }, ShouldPanic)
			So(func() { testRender(b, "hello") }, ShouldPanic)
			So(func() { testRender(b, 123) }, ShouldPanic)
			So(func() { testRender(b, []byte{}) }, ShouldPanic)
		})

		Convey("Converts errors to ServerError problems", func() {
			w := testRender(b, errors.New("broke"))
			So(w.Body.String(), ShouldContainSubstring, "server_error")
			So(w.Code, ShouldEqual, 500)
			// don't expose private error info
			So(w.Body.String(), ShouldNotContainSubstring, "broke")
		})
	})

}
