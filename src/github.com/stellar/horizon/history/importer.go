package history

import (
	"time"

	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// Close causes the importer to shut down.
func (i *Importer) Close() {
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
		go i.run()
	})
	return nil
}

// run causes the importer to check stellar-core to see if we can import new
// data.
func (i *Importer) run() {
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
			log.Warnf("could not load ledger state: %s", err)
			return
		}

		// 2.
		if i.lastState.UpToDate() {
			return
		}

		start, end := i.lastState.HorizonSequence, i.lastState.StellarCoreSequence

		for j := start; j < end; j++ {
			seq := j + 1
			err := i.ImportLedger(seq)

			if err != nil {
				log.Warnf("failed to import ledger %d: %s", seq, err)
				return
			}
		}

		// 3. no-op, the for loop brings us back to 1.
	}

}
