package actions

import (
	"fmt"
	"math"
	"net/http"
	"net/url"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"github.com/zenazn/goji/web"
)

func TestHelpers(t *testing.T) {
	Convey("Action Helpers", t, func() {
		r, _ := http.NewRequest("GET", "/?limit=2&cursor=hello", nil)

		action := &Base{
			Ctx: test.Context(),
			GojiCtx: web.C{
				URLParams: map[string]string{
					"blank": "",
					"zero":  "0",
					"two":   "2",
					"32min": fmt.Sprint(math.MinInt32),
					"32max": fmt.Sprint(math.MaxInt32),
					"64min": fmt.Sprint(math.MinInt64),
					"64max": fmt.Sprint(math.MaxInt64),
				},
				Env: map[interface{}]interface{}{},
			},
			R: r,
		}

		Convey("GetInt32", func() {
			result := action.GetInt32("blank")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt32("zero")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt32("two")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = action.GetInt32("32max")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MaxInt32)

			result = action.GetInt32("32min")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MinInt32)

			result = action.GetInt32("limit")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = action.GetInt32("64max")
			So(action.Err, ShouldNotBeNil)

			result = action.GetInt32("64min")
			So(action.Err, ShouldNotBeNil)

		})

		Convey("GetInt64", func() {
			result := action.GetInt64("blank")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt64("zero")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt64("two")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = action.GetInt64("64max")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MaxInt64)

			result = action.GetInt64("64min")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MinInt64)
		})

		Convey("GetPagingParams", func() {
			cursor, order, limit := action.GetPagingParams()
			So(cursor, ShouldEqual, "hello")
			So(limit, ShouldEqual, 2)
			So(order, ShouldEqual, "")
		})

		Convey("Last-Event-ID overrides cursor", func() {
			action.R.Header.Set("Last-Event-ID", "from_header")
			cursor, _, _ := action.GetPagingParams()
			So(cursor, ShouldEqual, "from_header")
		})

		Convey("Form values override query values", func() {
			So(action.GetString("cursor"), ShouldEqual, "hello")

			action.R.Form = url.Values{
				"cursor": {"goodbye"},
			}
			So(action.GetString("cursor"), ShouldEqual, "goodbye")
		})

		Convey("regression: GetPagQuery does not overwrite err", func() {
			r, _ := http.NewRequest("GET", "/?limit=foo", nil)
			action.R = r
			_, _, _ = action.GetPagingParams()

			So(action.Err, ShouldNotBeNil)
			_ = action.GetPageQuery()
			So(action.Err, ShouldNotBeNil)
		})

		Convey("Path() return the action's http path", func() {
			r, _ := http.NewRequest("GET", "/foo-bar/blah?limit=foo", nil)
			action.R = r
			So(action.Path(), ShouldEqual, "/foo-bar/blah")
		})
	})
}
