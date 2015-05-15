package horizon

import (
	. "github.com/smartystreets/goconvey/convey"
	"testing"
)

func TestApp(t *testing.T) {
	Convey("NewApp establishes the app in its context", t, func() {
		app, err := NewApp(NewTestConfig())
		So(err, ShouldBeNil)
		defer app.Close()

		found, ok := AppFromContext(app.ctx)
		So(ok, ShouldBeTrue)
		So(found, ShouldEqual, app)
	})
}
