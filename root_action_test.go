package horizon

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestRootAction(t *testing.T) {

	Convey("GET /", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		rh := NewRequestHelper(app)

		w := rh.Get("/", test.RequestHelperNoop)

		So(w.Code, ShouldEqual, 200)
	})
}
