package problem

import (
	. "github.com/smartystreets/goconvey/convey"
	"golang.org/x/net/context"
	"net/http/httptest"
	"testing"
)

func TestMain(t *testing.T) {

	Convey("Common Problems", t, func() {
		render := func(p P) *httptest.ResponseRecorder {
			w := httptest.NewRecorder()
			Render(context.Background(), w, p)
			return w
		}

		Convey("NotFound", func() {
			w := render(NotFound)
			So(w.Code, ShouldEqual, 404)
			t.Log(w.Body.String())
		})

		Convey("ServerError", func() {
			w := render(ServerError)
			So(w.Code, ShouldEqual, 500)
			t.Log(w.Body.String())
		})

		Convey("RateLimitExceeded", func() {
			w := render(RateLimitExceeded)
			So(w.Code, ShouldEqual, 429)
			t.Log(w.Body.String())
		})
	})

	Convey("problem.FromError", t, func() {
		Convey("delegates to .Problem()", func() {

		})

		Convey("adds a backtrace to extras", func() {})
	})

}
