package server

import (
	"github.com/stellar/horizon/pkg/simplepath"
)

func initPathFinding(app *App) {
	app.paths = &simplepath.Finder{app.CoreQ()}
}

func init() {
	appInit.Add("path-finder", initPathFinding, "app-context", "log", "core-db")
}
