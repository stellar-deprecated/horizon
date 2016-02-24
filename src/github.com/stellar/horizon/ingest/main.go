// Package ingest contains the ingestion system for horizon.  This system takes
// data produced by the connected stellar-core database, transforms it and
// inserts it into the horizon database.
package ingest

import (
	"sync"
	"time"

	"github.com/rcrowley/go-metrics"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/records/core"
)

const (
	// CurrentVersion reflects the latest version of the ingestion
	// algorithm. As rows are ingested into the horizon database, this version is
	// used to tag them.  In the future, any breaking changes introduced by a
	// developer should be accompanied by an increase in this value.
	//
	// Scripts, that have yet to be ported to this codebase can then be leveraged
	// to re-ingest old data with the new algorithm, providing a seamless
	// transition when the ingested data's structure changes.
	CurrentVersion = 5
)

// LedgerBundle represents a single ledger's worth of novelty created by one
// ledger close
type LedgerBundle struct {
	Sequence        int32
	Header          core.LedgerHeader
	TransactionFees []core.TransactionFee
	Transactions    []core.Transaction
}

// Ingester represents the data ingestion subsystem of horizon.
type Ingester struct {
	initializer sync.Once

	// HorizonDB is the connection to the horizon database that ingested data will
	// be written to.
	HorizonDB db.SqlQuery

	// CoreDB is the stellar-core db that data is ingested from.
	CoreDB db.SqlQuery

	// Metrics provides the metrics for this ingester.
	Metrics struct {
		// TotalTimer exposes timing metrics about the rate and latency of
		// ledger ingestions from stellar-core
		TotalTimer metrics.Timer

		// FailedMeter records how often an import operation fails
		FailedMeter metrics.Meter

		// SuccessfulMeter records how often an import operation succeeds
		SuccessfulMeter metrics.Meter
	}

	tick      *time.Ticker
	lastState db.LedgerState
}

// Session represents a single attempt at ingesting data into the history
// database.
type Session struct {
	// Ingester is a reference to the ingestion system that spawned this session.
	Ingester *Ingester

	// FirstLedger is the beginning of the range of ledgers (inclusive) that will
	// attempt to be ingested in this session.
	FirstLedger int32
	// LastLedger is the end of the range of ledgers (inclusive) that will
	// attempt to be ingested in this session.
	LastLedger int32

	// TX is the sql transaction to be used for writing any rows into the horizon
	// database.
	TX *db.Tx

	//
	// Results fields
	//

	// Err is the error that caused this session to fail, if any.
	Err error

	// Ingested is the number of ledgers that were successfully ingested during
	// this session.
	Ingested int
}
