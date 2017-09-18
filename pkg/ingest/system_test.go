package ingest

import (
	"testing"

	"github.com/stellar/go/network"
	"github.com/stellar/horizon/pkg/test"
)

func TestClearAll(t *testing.T) {
	tt := test.Start(t).Scenario("kahuna")
	defer tt.Finish()
	is := sys(tt)

	err := is.ClearAll()

	tt.Require.NoError(err)

	// ensure no ledgers
	var found int
	err = tt.HorizonSession().GetRaw(&found, "SELECT COUNT(*) FROM history_ledgers")
	tt.Require.NoError(err)
	tt.Assert.Equal(0, found)
}

func TestValidation(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()

	sys := New(network.TestNetworkPassphrase, "", tt.CoreSession(), tt.HorizonSession())

	// intact chain
	for i := int32(2); i <= 57; i++ {
		tt.Assert.NoError(sys.validateLedgerChain(i))
	}
	_, err := tt.CoreSession().ExecRaw(
		`DELETE FROM ledgerheaders WHERE ledgerseq = ?`, 5,
	)
	tt.Require.NoError(err)

	// missing cur
	err = sys.validateLedgerChain(5)
	tt.Assert.Error(err)
	tt.Assert.Contains(err.Error(), "failed to load cur ledger")

	// missing prev
	err = sys.validateLedgerChain(6)
	tt.Assert.Error(err)
	tt.Assert.Contains(err.Error(), "failed to load prev ledger")

	// mismatched header
	_, err = tt.CoreSession().ExecRaw(`
		UPDATE ledgerheaders
		SET ledgerhash = ?
		WHERE ledgerseq = ?`, "00000", 8)
	tt.Require.NoError(err)

	err = sys.validateLedgerChain(9)
	tt.Assert.Error(err)
	tt.Assert.Contains(err.Error(), "cur and prev ledger hashes don't match")
}
