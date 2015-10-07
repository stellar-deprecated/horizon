package codes

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base/xdr"
	"testing"
)

func TestCodes(t *testing.T) {
	Convey("codes.String", t, func() {
		tests := []struct {
			Input    interface{}
			Expected string
			Err      error
		}{
			{xdr.TransactionResultCodeTxSuccess, "tx_success", nil},
			{xdr.OperationResultCodeOpBadAuth, "op_bad_auth", nil},
			{xdr.CreateAccountResultCodeCreateAccountLowReserve, "op_low_reserve", nil},
			{xdr.PaymentResultCodePaymentSrcNoTrust, "op_src_no_trust", nil},
			{0, "", ErrUnknownCode},
		}

		for _, test := range tests {
			actual, err := String(test.Input)

			if test.Err != nil {
				So(err, ShouldNotBeNil)
				So(err.Error(), ShouldEqual, test.Err.Error())
			} else {
				So(err, ShouldBeNil)
				So(actual, ShouldEqual, test.Expected)
			}
		}
	})

	Convey("codes.ForOperationResult", t, func() {
		//TODO: op_inner refers to inner result code
		//TODO: non op_inner uses the outer result code
		//TODO: one test for each operation type
	})
}
