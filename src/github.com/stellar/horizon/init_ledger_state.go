package horizon

func initLedgerState(app *App) {
	go func() {
		ticks := app.pump.Subscribe()

		for _ = range ticks {
			app.UpdateLedgerState()
		}
	}()

}

func init() {
	appInit.Add("ledger-state", initLedgerState, "app-context", "log", "history-db", "core-db", "pump")
}
