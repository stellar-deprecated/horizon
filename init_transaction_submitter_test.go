package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestTransactionSubmitter(t *testing.T) {

	Convey("app.submitter gets set", t, func() {
		c := NewTestConfig()
		app, _ := NewApp(c)
		defer app.Close()

		So(app.submitter, ShouldNotBeNil)
	})
}
