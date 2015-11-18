package hal

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestLinkBuilder(t *testing.T) {

	Convey("Link Expansion", t, func() {

		check := func(href string, host string, expectedResult string) {
			lb := LinkBuilder{host}
			result := lb.expandLink(href)
			So(result, ShouldEqual, expectedResult)
		}

		check("/root", "", "/root")
		check("/root", "stellar.org", "//stellar.org/root")
		check("//else.org/root", "stellar.org", "//else.org/root")
		check("https://else.org/root", "stellar.org", "https://else.org/root")
	})

}
