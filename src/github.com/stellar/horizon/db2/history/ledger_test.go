package history

import (
	"database/sql"
	"testing"

	"github.com/stellar/horizon/test"
)

func TestLedgerQueries(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.HorizonRepo()}

	// Test LedgerBySequence
	var l Ledger
	err := q.LedgerBySequence(&l, 3)
	tt.Assert.NoError(err)

	err = q.LedgerBySequence(&l, 100000)
	tt.Assert.Equal(err, sql.ErrNoRows)

	// Test Ledgers()
	ls := []Ledger{}
	err = q.Ledgers().Select(&ls)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(ls, 3)
	}
}
