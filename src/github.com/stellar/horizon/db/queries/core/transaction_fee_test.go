package core

import (
	_ "github.com/lib/pq"
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestTransactionFeeByLedger(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.CoreRepo()}

	var fees []core.TransactionFee
	err := q.TransactionFeeByLedger(&fees, 2)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(fees, 3)
	}
}
