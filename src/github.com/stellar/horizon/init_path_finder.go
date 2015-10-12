package horizon

import (
	"github.com/stellar/horizon/paths"
)

func initPathFinding(app *App) {
	app.paths = &paths.DummyFinder{}
}

func init() {
	appInit.Add("path-finder", initPathFinding, "app-context", "log", "core-db")
}
