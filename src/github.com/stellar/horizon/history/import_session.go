package history

import (
	"fmt"
	"time"

	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
	// "golang.org/x/net/context"
)

// Import runs an import of the range of ledgers specified in this session.
func (is *ImportSession) Import() {
	// 1. start transaction
	is.TX, is.Err = db.Begin(is.Importer.HistoryDB)
	defer is.TX.Commit()

	if is.Err != nil {
		return
	}
	for seq := is.FirstLedger; seq <= is.LastLedger; seq++ {
		is.Importer.Metrics.ImportTimer.Time(func() {
			is.importSingle(seq)
		})

		if is.Err != nil {
			is.Importer.Metrics.FailedImportMeter.Mark(1)
			is.TX.Rollback()
			return
		}

		is.Importer.Metrics.SuccessfulImportMeter.Mark(1)
		is.Imported++
	}
}

func (is *ImportSession) importSingle(seq int32) {
	log.Debugf("importing ledger %d", seq)
	// TODO: load a history bundle for this sequence

	ib := is.TX.Insert("history_ledgers").Columns(
		"importer_version", "sequence", "ledger_hash", "previous_ledger_hash",
		"total_coins", "fee_pool", "base_fee", "base_reserve", "max_tx_set_size",
		"closed_at",
		"created_at", "updated_at",
	).Values(
		CurrentImporterVersion, seq, fmt.Sprint(seq), fmt.Sprint(seq-1),
		0, 0, 0, 0, 0,
		time.Now().UTC(),
		time.Now().UTC(), time.Now().UTC(),
	)

	is.TX.ExecInsert(ib)
	is.Err = is.TX.Err

	// code from horizon-importer:
	// ledger_hash:          stellar_core_ledger.ledgerhash,
	// previous_ledger_hash: (stellar_core_ledger.prevhash unless first_ledger),
	// closed_at:            Time.at(stellar_core_ledger.closetime),
	// transaction_count:    stellar_core_transactions.length,
	// operation_count:      stellar_core_transactions.map(&:operation_count).sum,
	// importer_version:     VERSION,
	// total_coins:          stellar_core_ledger.total_coins,
	// fee_pool:             stellar_core_ledger.fee_pool,
	// base_fee:             stellar_core_ledger.base_fee,
	// base_reserve:         stellar_core_ledger.base_reserve,
	// max_tx_set_size:      stellar_core_ledger.max_tx_set_size,
	// })

	return
}
