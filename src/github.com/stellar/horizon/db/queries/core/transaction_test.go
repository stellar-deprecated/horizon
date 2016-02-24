package core

import (
	_ "github.com/lib/pq"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestTransactionByHash(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()

	var tx core.Transaction
	q := TransactionByHash{
		DB:   db.SqlQuery{DB: tt.CoreDB},
		Hash: "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d",
	}

	err := db.Get(tt.Ctx, &q, &tx)

	if tt.Assert.NoError(err) {
		tt.Assert.Equal("2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d", tx.TransactionHash)
		tt.Assert.Len(tx.Envelope.Tx.Operations, 1)
	}

	// Missing row
	q.Hash = "not_real"
	err = db.Get(tt.Ctx, &q, &tx)
	tt.Assert.Equal(db.ErrNoResults, err)
}

func TestTransactionByLedger(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()

	var txs []core.Transaction

	err := db.Select(tt.Ctx, &TransactionByLedger{
		DB:       db.SqlQuery{DB: tt.CoreDB},
		Sequence: 2,
	}, &txs)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(txs, 3)
	}
}
