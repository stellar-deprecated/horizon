package core

import (
	"testing"

	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/test"
)

func TestTransactionsQueries(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.CoreSession()}

	// Test TransactionsByLedger
	var txs []Transaction
	err := q.TransactionsByLedger(&txs, 2)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(txs, 3)
	}

	// Test TransactionByHash
	var tx Transaction
	err = q.TransactionByHash(&tx, "cebb875a00ff6e1383aef0fd251a76f22c1f9ab2a2dffcb077855736ade2659a")

	if tt.Assert.NoError(err) {
		tt.Assert.Equal(int32(3), tx.LedgerSequence)
	}
}

func TestMemo(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()

	var tx Transaction

	xdr.SafeUnmarshalBase64("AAAAAMvoFDdcyQrJAcBmRdyEnW6047pvlk4MS/4r0n/1WH8VAAAAZAACnMAAAAACAAAAAAAAAAEAAAARADEuMC4xb3dlcnJpZGUgbWUAAAAAAAABAAAAAQAAAACJzogbLxrrmN7N5JVQceSxl8jkED26RGzbyyRIpwTh6wAAAAoAAAAWaSBzaG91bGQgYmUgb3dlcnJpZGRlbgAAAAAAAQAAABVpIHNob3VsZCBiZSBvd2VycmlkZW4AAAAAAAAAAAAAAacE4esAAABA0GuCIEmKyQ2DRqt5+BOIqjVlHisjY6rK1IcOtzjIKCDgSAoiv5yhYe09PohBH91TXvAQ/LZJj5hVMihfMjtgCw==", &tx.Envelope)

	tt.Assert.Equal("1.0.1owerride me", tx.Memo().String)
}
