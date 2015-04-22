package main

import (
	"github.com/codegangsta/cli"
	"github.com/stellar/go-horizon"
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
	ccli.Flags = []cli.Flag{
		cli.StringFlag{
			Name:   "db",
			Usage:  "url of the postgres database to connect with",
			EnvVar: "DATABASE_URL",
		},

		cli.StringFlag{
			Name:   "port",
			Usage:  "url of the postgres database to connect with",
			EnvVar: "PORT",
		},
	}

	ccli.Before = func(c *cli.Context) (err error) {

		if !c.IsSet("db") {
			cli.ShowAppHelp(c)
			os.Exit(1)
		}

		if !c.IsSet("db") {
			cli.ShowAppHelp(c)
			os.Exit(1)
		}

		// Prep the application
		config := horizon.Config{
			DatabaseUrl: c.String("db"),
		}
		app, err = horizon.NewApp(config)
		return
	}

	ccli.Action = func(c *cli.Context) {
		app.Serve()
	}

	ccli.RunAndExitOnError()
}
