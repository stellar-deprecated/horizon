package ingest

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// Close causes the ingester to shut down.
func (i *Ingester) Close() {
	log.Info("canceling ingestion poller")
	i.tick.Stop()
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
	q := db.LedgerStateQuery{
		Horizon: i.HorizonDB,
		Core:    i.CoreDB,
	}

	// 1. find the latest ledger
	// 2. if any available, import until none available
	// 3. if any were imported, go to 1
	for {
		// 1.
		err := db.Get(context.Background(), q, &i.lastState)

		if err != nil {
			log.Errorf("could not load ledger state: %s", err)
			return
		}

		// 2.
		if i.lastState.UpToDate() {
			return
		}

		is := Session{
			Ingester:    i,
			FirstLedger: i.lastState.HorizonSequence + 1,
			LastLedger:  i.lastState.StellarCoreSequence,
		}

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
