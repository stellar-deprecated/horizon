package core

import (
	"testing"

	"github.com/stellar/horizon/pkg/test"
)

func TestLatestLedger(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.CoreSession()}

	var seq int
	err := q.LatestLedger(&seq)

	if tt.Assert.NoError(err) {
		tt.Assert.Equal(3, seq)
	}
}

func TestElderLedger(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()
	q := &Q{tt.CoreSession()}

	var elder int32
	err := q.ElderLedger(&elder)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(elder, int32(1))
	}

	// ledger 3 gets picked properly
	_, err = tt.CoreDB.Exec(`DELETE FROM ledgerheaders WHERE ledgerseq = 2`)
	tt.Require.NoError(err, "failed to remove ledgerheader")

	err = q.ElderLedger(&elder)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(elder, int32(3))
	}

	// a bigger inital gap is properly dealt with
	_, err = tt.CoreDB.Exec(`
		DELETE FROM ledgerheaders WHERE ledgerseq > 1 AND ledgerseq < 10
	`)
	tt.Require.NoError(err, "failed to remove ledgerheader")

	err = q.ElderLedger(&elder)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(elder, int32(10))
	}

	// a second gap is not considered for determining the elder ledger
	_, err = tt.CoreDB.Exec(`
		DELETE FROM ledgerheaders WHERE ledgerseq > 15 AND ledgerseq < 20
	`)
	tt.Require.NoError(err, "failed to remove ledgerheader")

	err = q.ElderLedger(&elder)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(elder, int32(10))
	}
}
