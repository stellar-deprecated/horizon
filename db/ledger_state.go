package db

import (
	"github.com/rcrowley/go-metrics"
)

// Represents the latest known ledgers for both
// horizon and stellar-core.
type LedgerState struct {
	HorizonSequence     int32
	StellarCoreSequence int32
}

func HorizonLedgerGauge() metrics.Gauge {
	return horizonLedgerGauge
}

func StellarCoreLedgerGauge() metrics.Gauge {
	return stellarCoreLedgerGauge
}

func UpdateLedgerState(horizon SqlQuery, core SqlQuery) error {
	q := LedgerStateQuery{horizon, core}
	record, err := First(q)

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
