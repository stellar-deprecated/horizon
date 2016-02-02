package history

import (
	"sync"
	"time"

	"github.com/rcrowley/go-metrics"
	"github.com/stellar/horizon/db"
)

const (
	// CurrentImporterVersion reflects the latest version of the import
	// algorithm. As rows are imported into the history database, this version is
	// used to tag them.  In the future, any breaking changes introduced by a
	// developer should be accompanied by an increase in this value.
	//
	// Scripts, that have yet to be ported to this codebase can then be leveraged
	// to re-import old data with the new algorithm, providing a seamless
	// transition when the imported data's structure changes.
	CurrentImporterVersion = 5
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
		// ImportTimer exposes timing metrics about the rate and latency of
		// ledger imports from stellar-core
		ImportTimer metrics.Timer

		// FailedImportMeter records how often an import operation fails
		FailedImportMeter metrics.Meter

		// FailedImportMeter records how often an import operation succeeds
		SuccessfulImportMeter metrics.Meter
	}

	tick      *time.Ticker
	lastState db.LedgerState
}

// ImportSession represents a single attempt at importing data into the history
// database.
type ImportSession struct {
	// Importer is a reference to the importer that spawned this session.
	Importer *Importer

	// FirstLedger is the beginning of the range of ledgers (inclusive) that will
	// attempt to be imported in this session.
	FirstLedger int32
	// LastLedger is the end of the range of ledgers (inclusive) that will
	// attempt to be imported in this session.
	LastLedger int32

	// TX is the sql transaction to be used for writing any rows into the history
	// database.
	TX *db.Tx

	//
	// Results fields
	//

	// Err is the error that caused this session to fail, if any.
	Err error

	// Imported is the number of ledgers that were imported
	Imported int
}
