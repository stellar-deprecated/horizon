package ingest

import (
	"testing"

	"github.com/stellar/horizon/test"
)

func TestCursor(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()

	//
	c := Cursor{
		FirstLedger: 7,
		LastLedger:  10,
		DB:          tt.CoreRepo(),
	}

	// Ledger 7
	tt.Require.True(c.NextLedger())
	tt.Require.True(c.NextTx())
	tt.Require.True(c.NextOp())
	tt.Require.False(c.NextOp())
	tt.Require.False(c.NextTx())

	// Ledger 8
	tt.Require.True(c.NextLedger())
	tt.Require.True(c.NextTx())
	tt.Require.True(c.NextOp())
	tt.Require.False(c.NextOp())
	tt.Require.True(c.NextTx())
	tt.Require.True(c.NextOp())
	tt.Require.False(c.NextOp())
	tt.Require.True(c.NextTx())
	tt.Require.True(c.NextOp())
	tt.Require.False(c.NextOp())
	tt.Require.True(c.NextTx())
	tt.Require.True(c.NextOp())
	tt.Require.False(c.NextOp())
	tt.Require.False(c.NextTx())

	// Ledger 9
	tt.Require.True(c.NextLedger())
	tt.Require.True(c.NextTx())
	tt.Require.True(c.NextOp())
	tt.Require.False(c.NextOp())
	tt.Require.False(c.NextTx())

	// Ledger 10
	tt.Require.True(c.NextLedger())
	tt.Require.True(c.NextTx())
	tt.Require.True(c.NextOp())
	tt.Require.True(c.NextOp())
	tt.Require.False(c.NextOp())
	tt.Require.False(c.NextTx())

	tt.Require.False(c.NextLedger())
}
