package reap

import (
	"github.com/stellar/horizon/errors"
	"github.com/stellar/horizon/ledger"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/toid"
)

// Close causes the ingester to shut down.
func (r *System) Close() {
	log.Info("canceling reaper poller")
	r.tick.Stop()
}

// DeleteUnretainedHistory removes all data associated with unretained ledgers.
func (r *System) DeleteUnretainedHistory() error {
	// RetentionCount of 0 indicates "keep all history"
	if r.RetentionCount == 0 {
		return nil
	}

	var (
		latest      = ledger.CurrentState()
		targetElder = (latest.HistoryLatest - int32(r.RetentionCount)) + 1
	)

	if targetElder < latest.HistoryElder {
		return nil
	}

	err := r.clearBefore(targetElder)
	if err != nil {
		return err
	}

	log.
		WithField("new_elder", targetElder).
		Info("reaper succeeded")

	return nil
}

// Start causes the reaper to begin periodically clearing unretained historical
// data from the horizon database.
func (r *System) Start() {
	go r.run()
}

func (r *System) run() {
	for _ = range r.tick.C {
		log.Debug("ticking reaper")
		r.runOnce()
	}
}

func (r *System) runOnce() {
	defer func() {
		if rec := recover(); rec != nil {
			err := errors.FromPanic(rec)
			log.Errorf("reaper panicked: %s", err)
			errors.ReportToSentry(err, nil)
		}
	}()

	err := r.DeleteUnretainedHistory()
	if err != nil {
		log.Errorf("reaper failed: %s", err)
	}
}

func (r *System) clearBefore(seq int32) error {
	log.WithField("new_elder", seq).Info("reaper: clearing")

	clear := r.HorizonDB.DeleteRange
	end := toid.New(seq, 0, 0).ToInt64()

	err := clear(0, end, "history_effects", "history_operation_id")
	if err != nil {
		return err
	}
	err = clear(0, end, "history_operation_participants", "history_operation_id")
	if err != nil {
		return err
	}
	err = clear(0, end, "history_operations", "id")
	if err != nil {
		return err
	}
	err = clear(0, end, "history_transaction_participants", "history_transaction_id")
	if err != nil {
		return err
	}
	err = clear(0, end, "history_transactions", "id")
	if err != nil {
		return err
	}
	err = clear(0, end, "history_ledgers", "id")
	if err != nil {
		return err
	}

	return nil
}
