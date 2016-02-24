package core

import (
	_ "github.com/lib/pq"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestTransactionFeeByHash(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()

	var fee core.TransactionFee
	q := TransactionFeeByHash{
		DB:   db.SqlQuery{DB: tt.CoreDB},
		Hash: "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d",
	}

	err := db.Get(tt.Ctx, &q, &fee)

	if tt.Assert.NoError(err) {
		tt.Assert.Equal("2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d", fee.TransactionHash)
	}

	// Missing row
	q.Hash = "not_real"
	err = db.Get(tt.Ctx, &q, &fee)
	tt.Assert.Equal(db.ErrNoResults, err)
}

func TestTransactionFeeByLedger(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()

	var fees []core.TransactionFee

	err := db.Select(tt.Ctx, &TransactionFeeByLedger{
		DB:       db.SqlQuery{DB: tt.CoreDB},
		Sequence: 2,
	}, &fees)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(fees, 3)
	}
}
