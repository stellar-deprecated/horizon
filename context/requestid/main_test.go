package requestid

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"testing"
)

func TestRequestId(t *testing.T) {
	Convey("requestid.Context", t, func() {
		ctx := Context(context.Background(), "2")
		So(ctx.Value(&key), ShouldEqual, "2")

		ctx2 := Context(ctx, "3")

		So(ctx.Value(&key), ShouldEqual, "2")
		So(ctx2.Value(&key), ShouldEqual, "3")
	})

	Convey("requestid.ContextFromC", t, func() {
		gojiC := web.C{
			Env: make(map[interface{}]interface{}),
		}

		gojiC.Env["reqID"] = "foobar"

		ctx := ContextFromC(context.Background(), &gojiC)
		So(FromContext(ctx), ShouldEqual, "foobar")
	})

	Convey("requestid.FromContext", t, func() {
		ctx := Context(context.Background(), "2")
		ctx2 := Context(ctx, "3")

		So(FromContext(context.Background()), ShouldEqual, "")
		So(FromContext(ctx), ShouldEqual, "2")
		So(FromContext(ctx2), ShouldEqual, "3")
	})
}
