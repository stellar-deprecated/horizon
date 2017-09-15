package problem

import (
	"errors"
	"net/http/httptest"
	"testing"

	ge "github.com/go-errors/errors"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/pkg/context/requestid"
	"github.com/stellar/horizon/pkg/test"
	"golang.org/x/net/context"
)

func TestProblemPackage(t *testing.T) {
	ctx := context.Background()

	testRender := func(ctx context.Context, p interface{}) *httptest.ResponseRecorder {
		w := httptest.NewRecorder()
		Render(ctx, w, p)
		return w
	}

	Convey("Common Problems", t, func() {
		Convey("NotFound", func() {
			w := testRender(ctx, NotFound)
			So(w.Code, ShouldEqual, 404)
			t.Log(w.Body.String())
		})

		Convey("ServerError", func() {
			w := testRender(ctx, ServerError)
			So(w.Code, ShouldEqual, 500)
			t.Log(w.Body.String())
		})

		Convey("RateLimitExceeded", func() {
			w := testRender(ctx, RateLimitExceeded)
			So(w.Code, ShouldEqual, 429)
			t.Log(w.Body.String())
		})
	})

	Convey("problem.Inflate", t, func() {
		Convey("sets Instance to the request id based upon the context", func() {
			ctx2 := requestid.Context(ctx, "2")
			p := P{}
			Inflate(ctx2, &p)

			So(p.Instance, ShouldEqual, "2")

			// when no request id is set, instance should be ""
			Inflate(ctx, &p)
			So(p.Instance, ShouldEqual, "")
		})
	})

	Convey("problem.Render", t, func() {
		Convey("renders the type correctly", func() {
			w := testRender(ctx, P{Type: "foo"})
			So(w.Body.String(), ShouldContainSubstring, "foo")
		})

		Convey("renders the status correctly", func() {
			w := testRender(ctx, P{Status: 201})
			So(w.Body.String(), ShouldContainSubstring, "201")
			So(w.Code, ShouldEqual, 201)
		})

		Convey("renders the extras correctly", func() {
			w := testRender(ctx, P{
				Extras: map[string]interface{}{"hello": "stellar"},
			})
			So(w.Body.String(), ShouldContainSubstring, "hello")
			So(w.Body.String(), ShouldContainSubstring, "stellar")
		})

		Convey("panics if non-compliant `p` is used", func() {
			So(func() { testRender(ctx, nil) }, ShouldPanic)
			So(func() { testRender(ctx, "hello") }, ShouldPanic)
			So(func() { testRender(ctx, 123) }, ShouldPanic)
			So(func() { testRender(ctx, []byte{}) }, ShouldPanic)
		})

		Convey("Converts errors to ServerError problems", func() {
			ctx, _ := test.ContextWithLogBuffer()
			w := testRender(ctx, errors.New("broke"))
			So(w.Body.String(), ShouldContainSubstring, "server_error")
			So(w.Code, ShouldEqual, 500)
			// don't expose private error info
			So(w.Body.String(), ShouldNotContainSubstring, "broke")
		})

		Convey("Logs the stacktrace as unknown for non-rich errors", func() {
			ctx, log := test.ContextWithLogBuffer()
			w := testRender(ctx, errors.New("broke"))
			So(w.Body.String(), ShouldContainSubstring, "server_error")
			So(w.Code, ShouldEqual, 500)
			So(log.String(), ShouldContainSubstring, "stack=unknown")
		})

		Convey("Logs the stacktrace properly for rich errors", func() {
			ctx, log := test.ContextWithLogBuffer()
			w := testRender(ctx, ge.New("broke"))
			So(w.Body.String(), ShouldContainSubstring, "server_error")
			So(w.Code, ShouldEqual, 500)
			// simple assert that this file shows up in the error report
			// TODO: make less brittle
			So(log.String(), ShouldContainSubstring, "main_test.go:")
		})
	})

}
