package ingest

import (
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/log"
)

// Close causes the ingester to shut down.
func (i *Ingester) Close() {
	log.Info("canceling ingestion poller")
	i.tick.Stop()
}

// ReingestAll re-ingests all ledgers
func (i *Ingester) ReingestAll() (int, error) {
	err := i.updateLedgerState()
	if err != nil {
		return 0, err
	}
	is := NewSession(1, i.coreSequence, i)
	is.ClearExisting = true
	is.Run()
	return is.Ingested, is.Err
}

// ReingestSingle re-ingests a single ledger
func (i *Ingester) ReingestSingle(sequence int32) error {
	is := NewSession(sequence, sequence, i)
	is.ClearExisting = true
	is.Run()
	return is.Err
}

// Start causes the ingester to begin polling the stellar-core database for now
// ledgers and ingesting data into the horizon database.
func (i *Ingester) Start() {
	go i.run()
}

func (i *Ingester) run() {
	for _ = range i.tick.C {
		log.Debug("ticking ingester")
		i.runOnce()
	}
}

// run causes the importer to check stellar-core to see if we can import new
// data.
func (i *Ingester) runOnce() {
	// 1. find the latest ledger
	// 2. if any available, import until none available
	// 3. if any were imported, go to 1
	for {
		// 1.
		err := i.updateLedgerState()

		if err != nil {
			log.Errorf("could not load ledger state: %s", err)
			return
		}

		// 2.
		if i.historySequence >= i.coreSequence {
			return
		}
		is := NewSession(
			i.historySequence+1,
			i.coreSequence,
			i,
		)

		is.Run()

		if is.Err != nil {
			log.Errorf("import session failed: %s", is.Err)
			return
		}

		// 3.
		if is.Ingested == 0 {
			return
		}
	}

}

func (i *Ingester) updateLedgerState() error {
	cq := &core.Q{Repo: i.CoreDB}
	hq := &history.Q{Repo: i.HorizonDB}

	err := cq.LatestLedger(&i.coreSequence)
	if err != nil {
		return err
	}

	err = hq.LatestLedger(&i.historySequence)
	if err != nil {
		return err
	}

	return nil
}
