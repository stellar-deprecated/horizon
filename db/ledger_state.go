package db

import (
	"github.com/rcrowley/go-metrics"
	"golang.org/x/net/context"
)

// LedgerState represents the latest known ledgers for both
// horizon and stellar-core.
type LedgerState struct {
	HorizonSequence     int32
	StellarCoreSequence int32
}

// HorizonLedgerGauge returns the guage that measures what the latest
// ledger is according to the history database.
func HorizonLedgerGauge() metrics.Gauge {
	return horizonLedgerGauge
}

// StellarCoreLedgerGauge returns the guage that measures what the latest
// ledger is according to the stellar-core-database.
func StellarCoreLedgerGauge() metrics.Gauge {
	return stellarCoreLedgerGauge
}

// UpdateLedgerState triggers an update of the ledger state guages.  It
// retrieves the latest known query from both the stellar-core database as well
// as the history database.
func UpdateLedgerState(ctx context.Context, horizon SqlQuery, core SqlQuery) error {
	q := LedgerStateQuery{horizon, core}
	record, err := First(ctx, q)

	if err != nil {
		return err
	}

	ls := record.(LedgerState)

	horizonLedgerGauge.Update(int64(ls.HorizonSequence))
	stellarCoreLedgerGauge.Update(int64(ls.StellarCoreSequence))
	return nil
}

var (
	latestLedgerState      LedgerState
	horizonLedgerGauge     metrics.Gauge
	stellarCoreLedgerGauge metrics.Gauge
)

func init() {
	horizonLedgerGauge = metrics.NewGauge()
	stellarCoreLedgerGauge = metrics.NewGauge()
}
