package horizon

import (
	"github.com/stellar/go-horizon/test"
	"log"
)

func NewTestApp() *App {
	app, err := NewApp(Config{DatabaseUrl: test.DatabaseUrl()})

	if err != nil {
		log.Panic(err)
	}

	app.historyDb.LogMode(true)

	return app
}
