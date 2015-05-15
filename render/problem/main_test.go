package problem

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/context/requestid"
	"golang.org/x/net/context"
	"net/http/httptest"
	"testing"
)

func TestMain(t *testing.T) {
	b := context.Background()

	Convey("Common Problems", t, func() {
		render := func(ctx context.Context, p P) *httptest.ResponseRecorder {
			w := httptest.NewRecorder()
			Render(ctx, w, p)
			return w
		}

		Convey("NotFound", func() {
			w := render(b, NotFound)
			So(w.Code, ShouldEqual, 404)
			t.Log(w.Body.String())
		})

		Convey("ServerError", func() {
			w := render(b, ServerError)
			So(w.Code, ShouldEqual, 500)
			t.Log(w.Body.String())
		})

		Convey("RateLimitExceeded", func() {
			w := render(b, RateLimitExceeded)
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

	Convey("problem.FromError", t, func() {
		Convey("delegates to .Problem()", func() {

		})

		Convey("adds a backtrace to extras", func() {})
	})

}
