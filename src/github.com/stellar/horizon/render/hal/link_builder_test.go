package hal

import (
	"net/url"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestLinkBuilder(t *testing.T) {

	Convey("Link Expansion", t, func() {

		check := func(href string, base *url.URL, expectedResult string) {
			lb := LinkBuilder{base}
			result := lb.expandLink(href)
			So(result, ShouldEqual, expectedResult)
		}

		check("/root", nil, "/root")
		check("/root", mustParseURL("//stellar.org"), "//stellar.org/root")
		check("//else.org/root", mustParseURL("//stellar.org"), "//else.org/root")
		check("https://else.org/root", mustParseURL("//stellar.org"), "https://else.org/root")
	})

}

func mustParseURL(in string) *url.URL {
	u, err := url.Parse(in)
	if err != nil {
		panic(err)
	}
	return u
}
