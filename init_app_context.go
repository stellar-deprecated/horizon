package horizon

import (
	"golang.org/x/net/context"
)

func initAppContext(app *App) {
	app.ctx, app.cancel = context.WithCancel(context.Background())
}

func init() {
	appInit.Add("app-context", initAppContext)
}
