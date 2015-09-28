package txsub

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"net/http"
	"testing"
)

func TestDefaultSubmitter(t *testing.T) {

	Convey("submitter (The default Submitter implementation)", t, func() {

		Convey("submits to the configured stellar-core instance correctly", func() {
			server := test.NewStaticMockServer(`{
				"status": "PENDING",
				"error": null
				}`)
			defer server.Close()

			s := NewDefaultSubmitter(http.DefaultClient, server.URL)
			sr := s.Submit("hello")
			So(sr.Err, ShouldBeNil)
			So(sr.Duration, ShouldBeGreaterThan, 0)
			So(server.LastRequest.URL.Query().Get("blob"), ShouldEqual, "hello")
		})

		Convey("succeeds when the stellar-core responds with DUPLICATE status", func() {
			server := test.NewStaticMockServer(`{
				"status": "DUPLICATE",
				"error": null
				}`)
			defer server.Close()

			s := NewDefaultSubmitter(http.DefaultClient, server.URL)
			sr := s.Submit("hello")
			So(sr.Err, ShouldBeNil)
		})

		Convey("errors when the stellar-core url is empty", func() {
			s := NewDefaultSubmitter(http.DefaultClient, "")
			sr := s.Submit("hello")
			So(sr.Err, ShouldNotBeNil)
		})

		Convey("errors when the stellar-core url is not parseable", func() {
			s := NewDefaultSubmitter(http.DefaultClient, "http://Not a url")
			sr := s.Submit("hello")
			So(sr.Err, ShouldNotBeNil)
		})

		Convey("errors when the stellar-core url is not reachable", func() {
			s := NewDefaultSubmitter(http.DefaultClient, "http://127.0.0.1:65535")
			sr := s.Submit("hello")
			So(sr.Err, ShouldNotBeNil)
		})

		Convey("errors when the stellar-core returns an unparseable response", func() {
			server := test.NewStaticMockServer(`{`)
			defer server.Close()

			s := NewDefaultSubmitter(http.DefaultClient, server.URL)
			sr := s.Submit("hello")
			So(sr.Err, ShouldNotBeNil)
		})

		Convey("errors when the stellar-core returns an exception response", func() {
			server := test.NewStaticMockServer(`{"exception": "Invalid XDR"}`)
			defer server.Close()

			s := NewDefaultSubmitter(http.DefaultClient, server.URL)
			sr := s.Submit("hello")
			So(sr.Err, ShouldNotBeNil)
			So(sr.Err.Error(), ShouldContainSubstring, "Invalid XDR")
		})

		Convey("errors when the stellar-core returns an unrecognized status", func() {
			server := test.NewStaticMockServer(`{"status": "NOTREAL"}`)
			defer server.Close()

			s := NewDefaultSubmitter(http.DefaultClient, server.URL)
			sr := s.Submit("hello")
			So(sr.Err, ShouldNotBeNil)
			So(sr.Err.Error(), ShouldContainSubstring, "NOTREAL")
		})

		Convey("errors when the stellar-core returns an error response", func() {
			server := test.NewStaticMockServer(`{"status": "ERROR", "error": "1234"}`)
			defer server.Close()

			s := NewDefaultSubmitter(http.DefaultClient, server.URL)
			sr := s.Submit("hello")
			So(sr.Err, ShouldHaveSameTypeAs, &FailedTransactionError{})
			ferr := sr.Err.(*FailedTransactionError)
			So(ferr.ResultXDR, ShouldEqual, "1234")
		})
	})
}
