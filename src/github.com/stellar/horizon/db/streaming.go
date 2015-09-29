package db

import (
	"database/sql"
	"time"

	"github.com/stellar/horizon/log"

	"golang.org/x/net/context"
)

const (
	MaxHistoryLedger = "SELECT MAX(sequence) FROM history_ledgers"
)

// NewLedgerClosePump starts a background proc that continually watches the
// history database provided.  The watch is stopped after the provided context
// is cancelled.
//
// Every second, the proc spawned by calling this func will check to see
// if a new ledger has been imported (by ruby-horizon as of 2015-04-30, but
// should eventually end up being in this project).  If a new ledger is seen
// the the channel returned by this function emits
func NewLedgerClosePump(ctx context.Context, db *sql.DB) <-chan struct{} {
	result := make(chan struct{})

	go func() {
		var lastSeenLedger int32
		for {
			select {
			case <-time.After(1 * time.Second):
				var latestLedger int32
				row := db.QueryRow(MaxHistoryLedger)
				err := row.Scan(&latestLedger)

				if err != nil {
					log.Warn(ctx, "Failed to check latest ledger", err)
					break
				}

				if latestLedger > lastSeenLedger {
					log.Debugf(ctx, "saw new ledger: %d, prev: %d", latestLedger, lastSeenLedger)

					select {
					case result <- struct{}{}:
						lastSeenLedger = latestLedger
					default:
						log.Debug(ctx, "ledger pump channel is blocked.  waiting...")
					}
				}

			case <-ctx.Done():
				log.Info(ctx, "canceling ledger pump")
				close(result)
				return
			}
		}
	}()

	return result
}
