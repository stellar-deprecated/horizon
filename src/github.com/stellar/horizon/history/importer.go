package history

import (
	"time"

	"github.com/rcrowley/go-metrics"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// Close causes the importer to shut down.
func (i *Importer) Close() {
	log.Info("canceling importer poller")
	i.tick.Stop()
}

// ImportLedger imports the ledger at the provided sequence number into the
// history database.
func (i *Importer) ImportLedger(seq int32) error {
	log.Debugf("Importing ledger %d", seq)
	return nil
}

// Init initializes the importer, causing it to begin polling the stellar-core
// database for now ledgers and importing data into the history databae.
func (i *Importer) Init() error {
	i.initializer.Do(func() {
		i.tick = time.NewTicker(1 * time.Second)
		i.Metrics.ImportTimer = metrics.NewTimer()
		i.Metrics.SuccessfulImportMeter = metrics.NewMeter()
		i.Metrics.FailedImportMeter = metrics.NewMeter()
		go i.run()
	})
	return nil
}
func (i *Importer) run() {
	for _ = range i.tick.C {
		log.Debug("ticking importer")
		i.runOnce()
	}
}

// run causes the importer to check stellar-core to see if we can import new
// data.
func (i *Importer) runOnce() {
	q := db.LedgerStateQuery{
		Horizon: i.HistoryDB,
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

		is := ImportSession{
			Importer:    i,
			FirstLedger: i.lastState.HorizonSequence + 1,
			LastLedger:  i.lastState.StellarCoreSequence,
		}

		is.Import()

		if is.Err != nil {
			log.Errorf("import session failed: %s", is.Err)
			return
		}

		// 3.
		if is.Imported == 0 {
			return
		}
	}

}
