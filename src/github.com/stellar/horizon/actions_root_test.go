package horizon

import (
	"encoding/json"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestRootAction(t *testing.T) {

	Convey("GET /", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		app.coreVersion = "test-core"
		app.horizonVersion = "test-horizon"

		defer app.Close()
		rh := NewRequestHelper(app)

		w := rh.Get("/", test.RequestHelperNoop)

		So(w.Code, ShouldEqual, 200)

		var result RootResource
		err := json.Unmarshal(w.Body.Bytes(), &result)
		So(err, ShouldBeNil)

		So(result.HorizonVersion, ShouldEqual, "test-horizon")
		So(result.StellarCoreVersion, ShouldEqual, "test-core")

	})
}
