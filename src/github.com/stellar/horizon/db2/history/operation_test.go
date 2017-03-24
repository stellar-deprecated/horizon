package history

import (
	"testing"

	"github.com/stellar/horizon/test"
)

func TestOperationQueries(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.HorizonSession()}

	// Test OperationByID
	var op Operation
	err := q.OperationByID(&op, 8589938689)

	if tt.Assert.NoError(err) {
		tt.Assert.Equal(int64(8589938689), op.ID)
	}

	// Test Operations()
	ops := []Operation{}
	err = q.Operations().
		ForAccount("GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON").
		Select(&ops)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(ops, 2)
	}

	// ledger filter works
	ops = []Operation{}
	err = q.Operations().ForLedger(2).Select(&ops)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(ops, 3)
	}

	// tx filter works
	hash := "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d"
	ops = []Operation{}
	err = q.Operations().ForTransaction(hash).Select(&ops)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(ops, 1)
	}

	// payment filter works
	tt.Scenario("pathed_payment")
	ops = []Operation{}
	err = q.Operations().OnlyPayments().Select(&ops)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(ops, 10)
	}
}
