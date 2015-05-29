package httpx

import (
	"net/http"
	"testing"

	"golang.org/x/net/context"

	. "github.com/smartystreets/goconvey/convey"
)

func TestClientContext(t *testing.T) {

	Convey("ClientFromContext works", t, func() {
		// returns the default client
		So(ClientFromContext(context.Background()), ShouldEqual, defaultClient)

		// returns a set client
		c := &http.Client{}
		ctx := ClientContext(context.Background(), c)
		So(ClientFromContext(ctx), ShouldEqual, c)
	})

	Convey("ClientContext panics if nil is used", t, func() {
		So(func() {
			ClientContext(context.Background(), nil)
		}, ShouldPanic)
	})
}
