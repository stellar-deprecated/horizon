package horizon

import (
	"github.com/stellar/horizon/db"
)

func initPathFinding(app *App) {
	app.paths = &db.SimplePathFinder{app.CoreQuery(), app.ctx}
}

func init() {
	appInit.Add("path-finder", initPathFinding, "app-context", "log", "core-db")
}
