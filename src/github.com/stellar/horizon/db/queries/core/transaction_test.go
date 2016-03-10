package core

import (
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestTransactionsByLedger(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.CoreRepo()}

	var txs []core.Transaction
	err := q.TransactionsByLedger(&txs, 2)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(txs, 3)
	}
}
