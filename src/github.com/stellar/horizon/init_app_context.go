package horizon

import (
	"golang.org/x/net/context"
)

func initAppContext(app *App) {
	ctx, cancel := context.WithCancel(context.Background())
	app.ctx = context.WithValue(ctx, &appContextKey, app)
	app.cancel = cancel
}

func init() {
	appInit.Add("app-context", initAppContext)
}
