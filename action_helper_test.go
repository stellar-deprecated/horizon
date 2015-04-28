package horizon

import (
	"fmt"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/zenazn/goji/web"
	"math"
	"testing"
)

func TestActionHelper(t *testing.T) {
	Convey("Action Helper", t, func() {
		c := web.C{}
		c.URLParams = map[string]string{
			"zero":  "0",
			"two":   "2",
			"32min": fmt.Sprint(math.MinInt32),
			"32max": fmt.Sprint(math.MaxInt32),
			"64min": fmt.Sprint(math.MinInt64),
			"64max": fmt.Sprint(math.MaxInt64),
		}
		c.Env = make(map[interface{}]interface{})

		ah := &ActionHelper{c: c}

		Convey("GetInt32", func() {
			result := ah.GetInt32("zero")
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

			result = ah.GetInt32("64max")
			So(ah.Err(), ShouldNotBeNil)

			result = ah.GetInt32("64min")
			So(ah.Err(), ShouldNotBeNil)
		})

		Convey("GetInt64", func() {
			result := ah.GetInt64("zero")
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

	})
}
