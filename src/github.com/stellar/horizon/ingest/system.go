package ingest

import (
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/errors"
	"github.com/stellar/horizon/log"
)

// Close causes the ingester to shut down.
func (i *System) Close() {
	log.Info("canceling ingestion poller")
	i.tick.Stop()
}

// ElderLedger represents the oldest "ingestable" ledger known to the
// stellar-core database this ingestion system is communicating with.  Horizon,
// which wants to operate on a contiguous range of ledger data (i.e. free from
// gaps) uses the elder ledger to start importing in the case of an empty
// database.
//
// Due to the design of stellar-core, ledger 1 will _always_ be in the database,
// even when configured to catchup minimally, so we cannot simply take
// MIN(ledgerseq). Instead, we can find whether or not 1 is the elder ledger by
// checking for the presence of ledger 2.
func (i *System) ElderLedger() (result int32, err error) {
	// otherwise, SELECT MIN(ledgerseq)

	var found bool
	err = i.CoreDB.GetRaw(&found, `
		SELECT CASE WHEN EXISTS (
		    SELECT *
		    FROM ledgerheaders
		    WHERE ledgerseq = 2
		)
		THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT) END
	`)

	if err != nil {
		return
	}

	// if ledger 2 is present, use it 1 as the elder ledger (since 1 is guaranteed
	// to be present)
	if found {
		result = 1
		return
	}

	err = i.CoreDB.GetRaw(&result, `
		SELECT MIN(ledgerseq)
		FROM ledgerheaders
		WHERE ledgerseq > 2
	`)

	return
}

// ReingestAll re-ingests all ledgers
func (i *System) ReingestAll() (int, error) {
	err := i.updateLedgerState()
	if err != nil {
		return 0, err
	}
	return i.ReingestRange(1, i.coreSequence)
}

// ReingestOutdated finds old ledgers and reimports them.
func (i *System) ReingestOutdated() (n int, err error) {
	q := history.Q{Repo: i.HorizonDB}

	// NOTE: this loop will never terminate if some bug were cause a ledger
	// reingestion to silently fail.
	for {
		outdated := []int32{}
		err = q.OldestOutdatedLedgers(&outdated, CurrentVersion)
		if err != nil {
			return
		}

		if len(outdated) == 0 {
			return
		}

		log.
			WithField("lowest_sequence", outdated[0]).
			WithField("batch_size", len(outdated)).
			Info("reingest: outdated")

		var start, end int32
		flush := func() error {
			ingested, ferr := i.ReingestRange(start, end)

			if ferr != nil {
				return ferr
			}
			n += ingested
			return nil
		}

		for idx := range outdated {
			seq := outdated[idx]

			if start == 0 {
				start = seq
				end = seq
				continue
			}

			if seq == end+1 {
				end = seq
				continue
			}

			err = flush()
			if err != nil {
				return
			}

			start = seq
			end = seq
		}

		err = flush()
		if err != nil {
			return
		}
	}
}

// ReingestRange reingests a range of ledgers, from `start` to `end`, inclusive.
func (i *System) ReingestRange(start, end int32) (int, error) {
	is := NewSession(start, end, i)
	is.ClearExisting = true
	is.Run()
	return is.Ingested, is.Err
}

// ReingestSingle re-ingests a single ledger
func (i *System) ReingestSingle(sequence int32) error {
	_, err := i.ReingestRange(sequence, sequence)
	return err
}

// Start causes the ingester to begin polling the stellar-core database for now
// ledgers and ingesting data into the horizon database.
func (i *System) Start() {
	go i.run()
}

func (i *System) run() {
	for _ = range i.tick.C {
		log.Debug("ticking ingester")
		i.runOnce()
	}
}

// run causes the importer to check stellar-core to see if we can import new
// data.
func (i *System) runOnce() {

	defer func() {
		if rec := recover(); rec != nil {
			err := errors.FromPanic(rec)
			log.Errorf("import session panicked: %s", err)
			errors.ReportToSentry(err, nil)
		}
	}()

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

func (i *System) updateLedgerState() error {
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
