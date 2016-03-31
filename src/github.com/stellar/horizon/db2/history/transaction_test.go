package history

import (
	"database/sql"
	"testing"

	"github.com/stellar/horizon/test"
)

func TestTransactionQueries(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.HorizonRepo()}

	// Test TransactionByHash
	var tx Transaction
	real := "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d"
	err := q.TransactionByHash(&tx, real)
	tt.Assert.NoError(err)

	fake := "not_real"
	err = q.TransactionByHash(&tx, fake)
	tt.Assert.Equal(err, sql.ErrNoRows)
}
