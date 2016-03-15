package ingest

import (
	"testing"

	"github.com/stellar/horizon/test"
)

func TestLedgerBundleLoad(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()

	bundle := &LedgerBundle{Sequence: 5}
	err := bundle.Load(tt.CoreRepo())

	if tt.Assert.NoError(err) {
		tt.Assert.Equal(uint32(5), bundle.Header.Sequence)
		tt.Assert.Len(bundle.Transactions, 3)
		tt.Assert.Len(bundle.TransactionFees, 3)
	}
}
