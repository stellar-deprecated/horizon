package main

import (
	"github.com/codegangsta/cli"
	"github.com/stellar/go-horizon"
	"github.com/zenazn/goji"
	"os"
	"runtime"
)

var app *horizon.App

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	ccli := cli.NewApp()
	ccli.Name = "horizon"
	ccli.Usage = "client-facing api server for the stellar network"
	ccli.Author = "Scott Fleckenstein <scott@stellar.org>"
	ccli.Version = "0.0.1"
	ccli.Flags = []cli.Flag{}

	ccli.Before = func(c *cli.Context) (err error) {
		// Prep the application
		config := horizon.Config{}
		app, err = horizon.NewApp(config)
		return
	}

	ccli.Action = func(c *cli.Context) {

		goji.Handle("/*", app.Router())
		goji.Serve()
	}

	ccli.Run(os.Args)
}
