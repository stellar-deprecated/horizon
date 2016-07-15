package ingest

import (
	err2 "github.com/pkg/errors"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/errors"
	"github.com/stellar/horizon/ledger"
	"github.com/stellar/horizon/log"
)

// Close causes the ingester to shut down.
func (i *System) Close() {
	log.Info("canceling ingestion poller")
	i.tick.Stop()
}

// ReingestAll re-ingests all ledgers
func (i *System) ReingestAll() (int, error) {
	err := i.updateLedgerState()
	if err != nil {
		return 0, err
	}
	ls := ledger.CurrentState()
	return i.ReingestRange(ls.CoreElder, ls.CoreLatest)
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
	// 2. if any ledgers are available, validate that a new ledger is on the chain
	// 3. import until none available
	// 4. if any were imported, go to 1
	for {
		// 1.
		err := i.updateLedgerState()

		if err != nil {
			log.Errorf("could not load ledger state: %s", err)
			return
		}

		var (
			start int32
			ls    = ledger.CurrentState()
		)

		if ls.HorizonLatest == 0 {
			start = ls.CoreElder
			log.Infof("history db is empty, starting ingestion from ledger %d", start)
		} else {
			start = ls.HorizonLatest + 1
		}

		end := ls.CoreLatest

		// 2.
		if start > end {
			return
		}

		if start != ls.CoreElder {
			err := i.validateLedgerChain(start)
			if err != nil {
				log.
					WithField("start", start).
					Errorf("ledger gap detected (possible db corruption): %s", err)
				return
			}
		}

		// 3.
		is := NewSession(start, end, i)
		is.Run()

		if is.Err != nil {
			log.Errorf("import session failed: %s", is.Err)
			return
		}

		// 4.
		if is.Ingested == 0 {
			return
		}
	}

}

func (i *System) updateLedgerState() error {
	cq := &core.Q{Repo: i.CoreDB}
	hq := &history.Q{Repo: i.HorizonDB}

	var next ledger.State

	err := cq.ElderLedger(&next.CoreElder)
	if err != nil {
		return err
	}

	err = cq.LatestLedger(&next.CoreLatest)
	if err != nil {
		return err
	}

	err = hq.LatestLedger(&next.HorizonLatest)
	if err != nil {
		return err
	}

	err = hq.ElderLedger(&next.HorizonElder)
	if err != nil {
		return err
	}

	ledger.SetState(next)
	return nil
}

// validateLedgerChain helps to ensure the chain of ledger entries is contiguous
// within horizon.  It ensures the ledger at `seq` is a child of `seq - 1`.
func (i *System) validateLedgerChain(seq int32) error {
	var (
		cur  core.LedgerHeader
		prev core.LedgerHeader
	)

	q := &core.Q{i.CoreDB}

	err := q.LedgerHeaderBySequence(&cur, seq)
	if err != nil {
		return err2.Wrap(err, "validateLedgerChain: failed to load cur ledger")
	}

	err = q.LedgerHeaderBySequence(&prev, seq-1)
	if err != nil {
		return err2.Wrap(err, "validateLedgerChain: failed to load prev ledger")
	}

	if cur.PrevHash != prev.LedgerHash {
		return err2.New("cur and prev ledger hashes don't match")
	}

	return nil
}
