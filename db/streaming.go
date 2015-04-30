package db

import (
	"database/sql"
	"golang.org/x/net/context"
	"log"
	"time"
)

func init() {
	go globalStreamManager.Run()
	return
}

var globalStreamManager *streamManager = newStreamManager()

type StreamedQuery interface {
	Get() <-chan StreamRecord
	Cancel()
}

type StreamRecord struct {
	Record interface{}
	Err    error
}

func AutoPump(ctx context.Context) {
	go func() {
		for {
			select {
			case <-time.After(1 * time.Second):
				PumpStreamer()
			case <-ctx.Done():
				log.Println("canceling autopump")
				return
			}
		}
	}()
}

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
					log.Println("Failed to check latest ledger: " + err.Error())
					break
				}

				if latestLedger > lastSeenLedger {
					log.Printf("saw new ledger: %d, prev: %d", latestLedger, lastSeenLedger)
					PumpStreamer()
					lastSeenLedger = latestLedger
				}

			case <-ctx.Done():
				log.Println("canceling ledger pump")
				return
			}
		}
	}()
}

func Stream(ctx context.Context, query Query) StreamedQuery {
	return globalStreamManager.Add(ctx, query)
}

func CancelStream(q StreamedQuery) {
	q.Cancel()
}

// Triggers an execution cycle of any in-progress streaming queries
func PumpStreamer() {
	globalStreamManager.Pump()
}

type streamedQuery struct {
	records <-chan StreamRecord
}

func (s *streamedQuery) Get() <-chan StreamRecord {
	return s.records
}

func (s *streamedQuery) Cancel() {

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

func (sl *streamedQueryListener) Deliver(results []interface{}) bool {
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
