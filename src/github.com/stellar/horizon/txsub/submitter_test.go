package txsub

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestDefaultSubmitter(t *testing.T) {
	ctx := test.Context()
	_ = ctx
	Convey("submitter (The default Submitter implementation)", t, func() {

		Convey("submits to the configured stellar-core instance correctly", func() {

		})

		// Http request error
		// stellar-core exception response
		// stellar-core error response
		// stellar-core pending response
		// stellar-core duplicate response

	})
}
