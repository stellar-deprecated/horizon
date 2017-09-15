package horizon

import (
	"net/http"
	"testing"

	"github.com/stellar/horizon/pkg/render/sse"
	"github.com/stellar/horizon/pkg/test"
)

func TestNewApp(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()

	config := NewTestConfig()
	config.SentryDSN = "Not a url"

	tt.Assert.Panics(func() {
		app, _ := NewApp(config)
		app.Close()
	})
}

func TestGenericHTTPFeatures(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	// CORS
	w := ht.Get("/")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Empty(w.HeaderMap.Get("Access-Control-Allow-Origin"))
	}

	w = ht.Get("/", func(r *http.Request) {
		r.Header.Set("Origin", "somewhere.com")
	})

	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Equal(
			"somewhere.com",
			w.HeaderMap.Get("Access-Control-Allow-Origin"),
		)
	}

	// Trailing slash is stripped
	w = ht.Get("/ledgers")
	ht.Assert.Equal(200, w.Code)
	w = ht.Get("/ledgers/")
	ht.Assert.Equal(200, w.Code)
}

func TestMetrics(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	hl := ht.App.historyLatestLedgerGauge
	he := ht.App.historyElderLedgerGauge
	cl := ht.App.coreLatestLedgerGauge
	ce := ht.App.coreElderLedgerGauge

	ht.Require.EqualValues(0, hl.Value())
	ht.Require.EqualValues(0, he.Value())
	ht.Require.EqualValues(0, cl.Value())
	ht.Require.EqualValues(0, ce.Value())

	ht.App.UpdateLedgerState()
	ht.App.UpdateMetrics()

	ht.Require.EqualValues(3, hl.Value())
	ht.Require.EqualValues(1, he.Value())
	ht.Require.EqualValues(3, cl.Value())
	ht.Require.EqualValues(1, ce.Value())
}

func TestTick(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	// stop the ticker so we can manually do it
	ht.App.ticks.Stop()

	// Regression.  Insure that SSE is pumped on each tick.

	// force a tick to close replace the "Pumped()" chan, protecting the test from
	// any ticks caused before a.ticks.Stop() was ran.
	sse.Tick()

	ch := sse.Pumped()
	select {
	case <-ch:
		t.Error("sse.Pumped() triggered prior to tick")
		t.FailNow()
	default:
		// no-op, channel is in the correct state when we cannot read from it
	}

	sse.Tick()

	select {
	case <-ch:
		// no-op.  Success!
	default:
		t.Error("sse.Pumped() did not trigger after tick")
		t.FailNow()
	}
}
