package horizon

import (
	"fmt"
	"math"
	"net/http"
	"net/url"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/zenazn/goji/web"
)

func TestActionHelper(t *testing.T) {
	Convey("Action Helper", t, func() {
		c := web.C{}
		r, _ := http.NewRequest("GET", "/?limit=2&cursor=hello", nil)

		c.URLParams = map[string]string{
			"blank": "",
			"zero":  "0",
			"two":   "2",
			"32min": fmt.Sprint(math.MinInt32),
			"32max": fmt.Sprint(math.MaxInt32),
			"64min": fmt.Sprint(math.MinInt64),
			"64max": fmt.Sprint(math.MaxInt64),
		}
		c.Env = make(map[interface{}]interface{})

		ah := &ActionHelper{c: c, r: r}

		Convey("GetInt32", func() {
			result := ah.GetInt32("blank")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = ah.GetInt32("zero")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = ah.GetInt32("two")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = ah.GetInt32("32max")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, math.MaxInt32)

			result = ah.GetInt32("32min")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, math.MinInt32)

			result = ah.GetInt32("limit")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = ah.GetInt32("64max")
			So(ah.Err(), ShouldNotBeNil)

			result = ah.GetInt32("64min")
			So(ah.Err(), ShouldNotBeNil)

		})

		Convey("GetInt64", func() {
			result := ah.GetInt64("blank")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = ah.GetInt64("zero")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = ah.GetInt64("two")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = ah.GetInt64("64max")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, math.MaxInt64)

			result = ah.GetInt64("64min")
			So(ah.Err(), ShouldBeNil)
			So(result, ShouldEqual, math.MinInt64)
		})

		Convey("GetPagingParams", func() {
			// TODO: Just a smoke test for now.  Fill this out later
			c := web.C{
				Env: make(map[interface{}]interface{}),
			}
			r, _ := http.NewRequest("GET", "/?limit=2&cursor=hello", nil)

			ah := &ActionHelper{c: c, r: r}

			cursor, order, limit := ah.GetPagingParams()
			So(cursor, ShouldEqual, "hello")
			So(limit, ShouldEqual, 2)
			So(order, ShouldEqual, "")
		})

		Convey("Last-Event-ID overrides cursor", func() {
			c := web.C{
				Env: make(map[interface{}]interface{}),
			}
			r, _ := http.NewRequest("GET", "/?cursor=hello", nil)
			r.Header.Set("Last-Event-ID", "from_header")
			ah := &ActionHelper{c: c, r: r}

			cursor, _, _ := ah.GetPagingParams()
			So(cursor, ShouldEqual, "from_header")
		})

		Convey("Form values override query values", func() {
			c := web.C{
				Env: make(map[interface{}]interface{}),
			}
			r, _ := http.NewRequest("GET", "/?cursor=hello", nil)
			ah := &ActionHelper{c: c, r: r}
			So(ah.GetString("cursor"), ShouldEqual, "hello")

			r.Form = url.Values{
				"cursor": {"goodbye"},
			}
			So(ah.GetString("cursor"), ShouldEqual, "goodbye")
		})

	})
}
