package horizon

func initStellarCoreInfo(app *App) {
	app.UpdateStellarCoreInfo()
	return
}

func init() {
	appInit.Add("stellarCoreInfo", initStellarCoreInfo, "app-context", "log")
}
