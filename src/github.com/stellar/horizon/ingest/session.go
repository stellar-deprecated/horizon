package ingest

import (
	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/go-stellar-base/xdr"
)

// Run starts an attempt to ingest the range of ledgers specified in this
// session.
func (is *Session) Run() {
	is.Err = is.Ingestion.Start()
	if is.Err != nil {
		return
	}

	for is.Cursor.NextLedger() {
		is.clearLedger()
		is.ingestLedger()
		is.flush()
	}

	if is.Err != nil {
		is.Ingestion.Rollback()
		return
	}

	is.Err = is.Ingestion.Close()

	// TODO: metrics
	// TODO: validate ledger chain
	// TODO: clear data
	// TODO: flush inserts
	// TODO: record success

}

func (is *Session) clearLedger() {
	if is.Err != nil {
		return
	}

	if !is.ClearExisting {
		return
	}

	is.Err = is.Ingestion.Clear(is.Cursor.LedgerRange())
}

func (is *Session) flush() {
	if is.Err != nil {
		return
	}
	is.Err = is.Ingestion.Flush()
}

func (is *Session) ingestEffects() {
	if is.Err != nil {
		return
	}
	//TODO
}

func (is *Session) ingestOperation() {
	if is.Err != nil {
		return
	}

	is.Ingestion.Operation(is.Cursor)

	// Import the new account if one was created
	if is.Cursor.Operation().Body.Type == xdr.OperationTypeCreateAccount {
		op := is.Cursor.Operation().Body.MustCreateAccountOp()
		is.Ingestion.Account(is.Cursor.OperationID(), op.Destination.Address())
	}

	// TODO: import operation participants

	is.ingestEffects()
}

// injestSingle ingests the current ledger
func (is *Session) ingestLedger() {
	if is.Err != nil {
		return
	}

	is.Ingestion.Ledger(is.Cursor)

	// If this is ledger 1, create the root account
	if is.Cursor.LedgerSequence() == 1 {
		is.Ingestion.Account(1, keypair.Master(is.Ingestion.Ingester.Network).Address())
	}

	for is.Cursor.NextTx() {
		is.ingestTransaction()
	}

	is.Ingested++

	return
}

func (is *Session) ingestTransaction() {
	if is.Err != nil {
		return
	}

	is.Ingestion.Transaction(is.Cursor)

	for is.Cursor.NextOp() {
		is.ingestOperation()
	}
	// TODO: import transaction participants
}
