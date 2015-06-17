package db

import (
	"database/sql"
	"time"

	"github.com/stellar/go-horizon/log"

	"golang.org/x/net/context"
)

func init() {
	go globalStreamManager.Run()
	return
}

var globalStreamManager = newStreamManager()

type StreamedQuery interface {
	Get() <-chan StreamRecord
}

// The streaming query system flows errors that occur while executing queries
// in the background to connected clients.  `StreamRecord` is the means to do
// this and any consumer of streaming query results should check every message
// that comes through their channel for an error.
type StreamRecord struct {
	Record interface{}
	Err    error
}

// AutoPump starts a background proc that triggers the streaming query
// system to run once per second.
//
// Canceling the provided context will also cancel the pump.
//
// Useful for development.
func AutoPump(ctx context.Context) {
	go func() {
		for {
			select {
			case <-time.After(1 * time.Second):
				PumpStreamer()
			case <-ctx.Done():
				log.Info(ctx, "canceling autopump")
				return
			}
		}
	}()
}

// LedgerClosePump starts a background proc that continually watches the
// history database provided.  The watch is stopped after the provided context
// is cancelled.
//
// Every second, the proc spawned by calling this func will check to see
// if a new ledger has been imported (by ruby-horizon as of 2015-04-30, but
// should eventually end up being in this project).  If a new ledger is seen
// the proc triggers the streaming system to run all watched queries and
// update connected clients
func LedgerClosePump(ctx context.Context, db *sql.DB) {
	go func() {
		var lastSeenLedger int32
		for {
			select {
			case <-time.After(1 * time.Second):
				var latestLedger int32
				row := db.QueryRow("SELECT MAX(sequence) FROM history_ledgers")
				err := row.Scan(&latestLedger)

				if err != nil {
					log.Warn(ctx, "Failed to check latest ledger", err)
					break
				}

				if latestLedger > lastSeenLedger {
					log.Debugf(ctx, "saw new ledger: %d, prev: %d", latestLedger, lastSeenLedger)
					PumpStreamer()
					lastSeenLedger = latestLedger
				}

			case <-ctx.Done():
				log.Info(ctx, "canceling ledger pump")
				return
			}
		}
	}()
}

// Stream registers a query with the streaming database system.  Everytime that
// the streaming system is pumped (either through the LedgerClosePump or
// Autopump) the provided query will be executed again and any new records will
// be pushed onto the channel provided in the returned `StreamedQuery`
// interface.
func Stream(ctx context.Context, query Query) StreamedQuery {
	s := globalStreamManager.Add(ctx, query)
	go globalStreamManager.PumpOne(query)
	return s
}

// PumpStreamer triggers an execution cycle of any in-progress streaming queries
func PumpStreamer() {
	globalStreamManager.Pump()
}

type streamedQuery struct {
	records <-chan StreamRecord
}

func (s *streamedQuery) Get() <-chan StreamRecord {
	return s.records
}

type streamedQueryListener struct {
	ctx       context.Context
	sentCount int
	cancelled bool
	send      chan<- StreamRecord
	receive   chan StreamRecord
}

func (sl *streamedQueryListener) Run() {
	defer close(sl.send)

	for {
		select {
		case record, ok := <-sl.receive:
			if !ok {
				return
			}
			sl.send <- record
		case <-sl.ctx.Done():
			sl.cancelled = true
			return
		}
	}
}

func (sl *streamedQueryListener) Deliver(results []Record) bool {
	if sl.cancelled {
		return false
	}

	toSend := results[sl.sentCount:len(results)]
	for _, r := range toSend {
		sl.receive <- StreamRecord{Record: r}
		sl.sentCount++
	}

	return true
}

func (sl *streamedQueryListener) Close() {
	close(sl.receive)
}
