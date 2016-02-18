package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/pump"
	"time"
)

func initPump(app *App) {
	var trigger <-chan struct{}

	if app.config.Autopump {
		trigger = pump.Tick(1 * time.Second)
	} else {
		trigger = db.NewLedgerClosePump(app.ctx, app.horizonDb)
	}

	app.pump = pump.NewPump(trigger)
}

func init() {
	appInit.Add("pump", initPump, "app-context", "log", "horizon-db", "core-db")
}
