// Package ingest contains the ingestion system for horizon.  This system takes
// data produced by the connected stellar-core database, transforms it and
// inserts it into the horizon database.
package ingest

import (
	"time"

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

// Cursor iterates through a stellar core database's ledgers
type Cursor struct {
	// FirstLedger is the beginning of the range of ledgers (inclusive) that will
	// attempt to be ingested in this session.
	FirstLedger int32
	// LastLedger is the end of the range of ledgers (inclusive) that will
	// attempt to be ingested in this session.
	LastLedger int32
	// CoreDB is the stellar-core db that data is ingested from.
	CoreDB db.SqlQuery

	// Err is the error that caused this iteration to fail, if any.
	Err error

	lg   int32
	tx   int
	op   int
	data *LedgerBundle
}

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
	// HorizonDB is the connection to the horizon database that ingested data will
	// be written to.
	HorizonDB db.SqlQuery

	// CoreDB is the stellar-core db that data is ingested from.
	CoreDB db.SqlQuery

	// Network is the passphrase for the network being imported
	Network string

	tick      *time.Ticker
	lastState db.LedgerState
}

type Ingestion struct {
	// Ingester is parent of this ingestion.
	Ingester *Ingester

	// tx is the sql transaction to be used for writing any rows into the horizon
	// database.
	tx *db.Tx

	ledgers      ingestionBuffer
	transactions ingestionBuffer
	operations   ingestionBuffer
	effects      ingestionBuffer
	accounts     ingestionBuffer
}

// Session represents a single attempt at ingesting data into the history
// database.
type Session struct {
	Cursor    *Cursor
	Ingestion *Ingestion

	// ClearExisting causes the session to clear existing data from the horizon db
	// when the session is run.
	ClearExisting bool

	//
	// Results fields
	//

	// Err is the error that caused this session to fail, if any.
	Err error

	// Ingested is the number of ledgers that were successfully ingested during
	// this session.
	Ingested int
}

// New initializes the ingester, causing it to begin polling the stellar-core
// database for now ledgers and ingesting data into the horizon database.
func New(network string, core, horizon db.SqlQuery) *Ingester {
	i := &Ingester{
		Network:   network,
		HorizonDB: horizon,
		CoreDB:    core,
	}
	i.tick = time.NewTicker(1 * time.Second)
	return i
}

// RunOnce runs a single ingestion session
func RunOnce(network string, core, horizon db.SqlQuery) (*Session, error) {
	i := New(network, core, horizon)
	err := i.updateLedgerState()
	if err != nil {
		return nil, err
	}

	is := &Session{
		Ingestion: &Ingestion{
			Ingester: i,
		},
		Cursor: &Cursor{
			FirstLedger: i.lastState.HorizonSequence + 1,
			LastLedger:  i.lastState.StellarCoreSequence,
			CoreDB:      i.CoreDB,
		},
	}

	is.Run()

	return is, is.Err
}
