package render

import (
	"net/http"
	"testing"

	"golang.org/x/net/context"

	. "github.com/smartystreets/goconvey/convey"
)

func TestRenderPackage(t *testing.T) {

	Convey("render.Negotiate", t, func() {
		ctx := context.Background()

		r, err := http.NewRequest("GET", "/ledgers", nil)
		So(err, ShouldBeNil)
		r.Header.Add("Accept", "application/hal+json")
		So(Negotiate(ctx, r), ShouldEqual, MimeHal)

		Convey("Obeys the Accept header's prioritization", func() {

			r.Header.Set("Accept", "text/event-stream,application/hal+json")
			So(Negotiate(ctx, r), ShouldEqual, MimeEventStream)

			r.Header.Set("Accept", "text/event-stream;q=0.5,application/hal+json")
			So(Negotiate(ctx, r), ShouldEqual, MimeHal)
		})

		Convey("Defaults to HAL", func() {
			r.Header.Set("Accept", "")
			So(Negotiate(ctx, r), ShouldEqual, MimeHal)

			r.Header.Del("Accept")
			So(Negotiate(ctx, r), ShouldEqual, MimeHal)
		})

		Convey("Returns empty string for invalid type", func() {
			r.Header.Set("Accept", "text/plain")
			So(Negotiate(ctx, r), ShouldEqual, "")
		})

	})
}
