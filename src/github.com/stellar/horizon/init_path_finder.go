package horizon

import (
	"github.com/stellar/horizon/simplepath"
)

func initPathFinding(app *App) {
	app.paths = &simplepath.Finder{app.CoreQuery(), app.ctx}
}

func init() {
	appInit.Add("path-finder", initPathFinding, "app-context", "log", "core-db")
}
