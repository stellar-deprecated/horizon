package main

import (
	"github.com/codegangsta/cli"
	"github.com/stellar/go-horizon"
	"github.com/stellar/go-horizon/db"
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
			Name:   "stellar-core-db",
			Usage:  "url of the stellar-core postgres database to connect with",
			EnvVar: "STELLAR_CORE_DATABASE_URL",
		},

		cli.IntFlag{
			Name:   "port",
			Usage:  "url of the postgres database to connect with",
			EnvVar: "PORT",
			Value:  8000,
		},

		cli.BoolFlag{
			Name:   "autopump",
			Usage:  "pump streams every second, instead of once per ledger close",
			EnvVar: "AUTOPUMP",
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
			DatabaseUrl:            c.String("db"),
			StellarCoreDatabaseUrl: c.String("stellar-core-db"),
			Port: c.Int("port"),
		}
		app, err = horizon.NewApp(config)
		return
	}

	ccli.Action = func(c *cli.Context) {

		if c.Bool("autopump") {
			db.AutoPump()
		}

		app.Serve()
	}

	ccli.RunAndExitOnError()
}
