package horizon

import (
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

func initAppContext(app *App) {
	ctx, cancel := context.WithCancel(context.Background())
	ctx = context.WithValue(ctx, &appContextKey, app)

	ctx = log.Set(ctx, app.log)
	app.ctx = ctx
	app.cancel = cancel
}

func init() {
	appInit.Add(
		"app-context",
		initAppContext,
		"log",
	)
}
