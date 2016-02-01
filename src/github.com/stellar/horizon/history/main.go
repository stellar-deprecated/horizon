package history

import (
	"sync"
	"time"

	"github.com/rcrowley/go-metrics"
	"github.com/stellar/horizon/db"
)

// Importer represents the history importing subsystem of horizon.
type Importer struct {
	initializer sync.Once

	// HistoryDB is the connection to the history database that data will be
	// imported into from this instance.
	HistoryDB db.SqlQuery

	// CoreDB is the stellar-core db that transaction data is imported from.
	CoreDB db.SqlQuery

	// Metrics provides the metrics for this importer.
	Metrics struct {
		// LedgerTimer exposes timing metrics about the rate and latency of
		// ledger imports from stellar-core
		LedgerTimer metrics.Timer
	}

	tick      *time.Ticker
	lastState db.LedgerState
}
