package main

import (
	"github.com/PuerkitoBio/throttled"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/stellar/go-horizon"
	"log"
	"os"
	"runtime"
)

var app *horizon.App
var rootCmd *cobra.Command

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())
	rootCmd.Execute()
}

func init() {
	viper.SetDefault("port", 8000)
	viper.SetDefault("autopump", false)

	viper.BindEnv("port", "PORT")
	viper.BindEnv("autopump", "AUTOPUMP")
	viper.BindEnv("db-url", "DATABASE_URL")
	viper.BindEnv("stellar-core-db-url", "STELLAR_CORE_DATABASE_URL")
	viper.BindEnv("stellar-core-url", "STELLAR_CORE_URL")
	viper.BindEnv("friendbot-secret", "FRIENDBOT_SECRET")
	viper.BindEnv("per-hour-rate-limit", "PER_HOUR_RATE_LIMIT")
	viper.BindEnv("redis-url", "REDIS_URL")

	rootCmd = &cobra.Command{
		Use:   "horizon",
		Short: "client-facing api server for the stellar network",
		Long:  "client-facing api server for the stellar network",
		Run:   run,
	}

	rootCmd.Flags().String(
		"db-url",
		"",
		"horizon postgres database to connect with",
	)

	rootCmd.Flags().String(
		"stellar-core-db-url",
		"",
		"stellar-core postgres database to connect with",
	)

	rootCmd.Flags().String(
		"stellar-core-url",
		"",
		"stellar-core to connect with (for http commands)",
	)

	rootCmd.Flags().Int(
		"port",
		8000,
		"tcp port to listen on for http requests",
	)

	rootCmd.Flags().Bool(
		"autopump",
		false,
		"pump streams every second, instead of once per ledger close",
	)

	rootCmd.Flags().Int(
		"per-hour-rate-limit",
		3600,
		"max count of requests allowed in a one hour period, by remote ip address",
	)

	rootCmd.Flags().String(
		"redis-url",
		"",
		"redis to connect with, for rate limiting",
	)

	viper.BindPFlags(rootCmd.Flags())
}

func run(cmd *cobra.Command, args []string) {

	if viper.GetString("db-url") == "" {
		rootCmd.Help()
		os.Exit(1)
	}

	if viper.GetString("stellar-core-db-url") == "" {
		rootCmd.Help()
		os.Exit(1)
	}

	config := horizon.Config{
		DatabaseUrl:            viper.GetString("db-url"),
		StellarCoreDatabaseUrl: viper.GetString("stellar-core-db-url"),
		Autopump:               viper.GetBool("autopump"),
		Port:                   viper.GetInt("port"),
		RateLimit:              throttled.PerHour(viper.GetInt("per-hour-rate-limit")),
		RedisUrl:               viper.GetString("redis-url"),
	}

	var err error
	app, err = horizon.NewApp(config)

	if err != nil {
		log.Fatal(err.Error())
	}

	app.Serve()
}
