package ingest

import (
	"testing"

	"github.com/stellar/go-stellar-base/network"
	"github.com/stellar/horizon/test"
)

func TestValidation(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()

	sys := New(network.TestNetworkPassphrase, "", tt.CoreRepo(), tt.HorizonRepo())

	// intact chain
	for i := int32(2); i <= 59; i++ {
		tt.Assert.NoError(sys.validateLedgerChain(i))
	}
	_, err := tt.CoreRepo().ExecRaw(
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
	_, err = tt.CoreRepo().ExecRaw(`
		UPDATE ledgerheaders
		SET ledgerhash = ?
		WHERE ledgerseq = ?`, "00000", 8)
	tt.Require.NoError(err)

	err = sys.validateLedgerChain(9)
	tt.Assert.Error(err)
	tt.Assert.Contains(err.Error(), "cur and prev ledger hashes don't match")
}
