package ingest

import (
	// "fmt"
	"time"

	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
	// "golang.org/x/net/context"
)

// Run starts an attempt to ingest the range of ledgers specified in this
// session.
func (is *Session) Run() {
	// 1. start transaction
	is.TX, is.Err = db.Begin(is.Ingester.HorizonDB)
	defer is.TX.Commit()

	if is.Err != nil {
		return
	}
	for seq := is.FirstLedger; seq <= is.LastLedger; seq++ {
		is.Ingester.Metrics.TotalTimer.Time(func() {
			// Do the actual work
			is.ingestSingle(seq)
		})

		// Check and handle failure
		if is.Err != nil {
			is.Ingester.Metrics.FailedMeter.Mark(1)
			is.TX.Rollback()
			return
		}

		// Record success
		is.Ingester.Metrics.SuccessfulMeter.Mark(1)
		is.Ingested++

	}
}

func (is *Session) ingestSingle(seq int32) {
	if is.Err != nil {
		return
	}

	log.Debugf("ingesting ledger %d", seq)
	data := &LedgerBundle{Sequence: seq}
	is.Err = data.Load(is.Ingester.CoreDB)
	if is.Err != nil {
		return
	}

	is.do(
		func() { is.createRootAccountIfNeeded(data) },
		func() { is.validateLedgerChain(data) },
		func() { is.clearExistingDataIfNeeded(data) },
		func() { is.ingestHistoryLedger(data) },
		func() { is.ingestHistoryAccounts(data) },
		func() { is.ingestHistoryTransactions(data) },
		func() { is.ingestHistoryOperations(data) },
		func() { is.ingestHistoryEffects(data) },
	)

	return
}

func (is *Session) clearExistingDataIfNeeded(data *LedgerBundle) {
	// TODO: add re-import support
}

func (is *Session) createRootAccountIfNeeded(data *LedgerBundle) {
	if data.Sequence != 1 {
		return
	}

	ib := is.TX.Insert("history_accounts").
		Columns("id", "address").
		Values(1, keypair.Master(is.Ingester.Network).Address())

	is.TX.ExecInsert(ib)
	is.Err = is.TX.Err
}

func (is *Session) do(steps ...func()) {
	for _, step := range steps {
		if is.Err != nil {
			return
		}

		step()
	}
}

func (is *Session) ingestHistoryLedger(data *LedgerBundle) {

	ib := is.TX.Insert("history_ledgers").Columns(
		"importer_version",
		"sequence",
		"ledger_hash",
		"previous_ledger_hash",
		"total_coins",
		"fee_pool",
		"base_fee",
		"base_reserve",
		"max_tx_set_size",
		"closed_at",
		"created_at",
		"updated_at",
	).Values(
		CurrentVersion,
		data.Sequence,
		data.Header.LedgerHash,
		data.Header.PrevHash,
		data.Header.Data.TotalCoins,
		data.Header.Data.FeePool,
		data.Header.Data.BaseFee,
		data.Header.Data.BaseReserve,
		data.Header.Data.MaxTxSetSize,
		time.Unix(data.Header.CloseTime, 0).UTC(),
		time.Now().UTC(),
		time.Now().UTC(),
	)

	is.TX.ExecInsert(ib)
	is.Err = is.TX.Err

}

func (is *Session) ingestHistoryAccounts(data *LedgerBundle) {

}

func (is *Session) ingestHistoryTransactions(data *LedgerBundle) {

}

func (is *Session) ingestHistoryOperations(data *LedgerBundle) {

}

func (is *Session) ingestHistoryEffects(data *LedgerBundle) {

}

func (is *Session) validateLedgerChain(data *LedgerBundle) {
	// TODO: ensure prevhash exists in the database
}
