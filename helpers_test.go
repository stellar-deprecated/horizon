package horizon

import (
	"./test"
	"log"
)

func NewTestApp() *App {
	app, err := NewApp(Config{DatabaseUrl: test.DatabaseUrl()})

	if err != nil {
		log.Panic(err)
	}

	return app
}
