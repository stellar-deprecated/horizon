package codes

import (
	"testing"

	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/test"
)

func TestCodes_String(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()

	tests := []struct {
		Input       interface{}
		Expected    string
		ExpectedErr string
	}{
		{xdr.TransactionResultCodeTxSuccess, "tx_success", ""},
		{xdr.OperationResultCodeOpBadAuth, "op_bad_auth", ""},
		{xdr.CreateAccountResultCodeCreateAccountLowReserve, "op_low_reserve", ""},
		{xdr.PaymentResultCodePaymentSrcNoTrust, "op_src_no_trust", ""},
		{0, "", "Unknown result code"},
	}

	for _, test := range tests {
		actual, err := String(test.Input)

		if test.ExpectedErr != "" {
			tt.Assert.EqualError(err, test.ExpectedErr)
		} else {
			if tt.Assert.NoError(err) {
				tt.Assert.Equal(test.Expected, actual)
			}
		}
	}
}

func TestCodes_ForOperationResult(t *testing.T) {

	//TODO: op_inner refers to inner result code
	//TODO: non op_inner uses the outer result code
	//TODO: one test for each operation type

}
