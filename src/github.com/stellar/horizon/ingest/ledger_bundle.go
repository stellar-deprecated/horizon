package ingest

import (
	"github.com/stellar/horizon/db2"
)

// Load runs queries against `core` to fill in the records of the bundle.
func (lb *LedgerBundle) Load(db *db2.Repo) error {
	// Load Header
	err := db.GetRaw(
		&lb.Header,
		`SELECT * FROM ledgerheaders WHERE ledgerseq = ?`,
		lb.Sequence,
	)
	if err != nil {
		return err
	}

	// Load transactions
	err = db.SelectRaw(
		&lb.Transactions,
		`SELECT * FROM txhistory WHERE ledgerseq = ? ORDER BY txindex ASC`,
		lb.Sequence,
	)
	if err != nil {
		return err
	}

	err = db.SelectRaw(
		&lb.TransactionFees,
		`SELECT * FROM txfeehistory WHERE ledgerseq = ? ORDER BY txindex ASC`,
		lb.Sequence,
	)
	if err != nil {
		return err
	}

	return nil
}
