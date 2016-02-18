package main

import (
	"log"
	"os"
	"runtime"

	"github.com/PuerkitoBio/throttled"
	"github.com/Sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/stellar/horizon"
	hlog "github.com/stellar/horizon/log"
)

var app *horizon.App
var version string

var rootCmd *cobra.Command

func main() {
	if version != "" {
		horizon.SetVersion(version)
	}
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
	viper.BindEnv("ruby-horizon-url", "RUBY_HORIZON_URL")
	viper.BindEnv("log-level", "LOG_LEVEL")
	viper.BindEnv("sentry-dsn", "SENTRY_DSN")
	viper.BindEnv("loggly-token", "LOGGLY_TOKEN")
	viper.BindEnv("loggly-host", "LOGGLY_HOST")
	viper.BindEnv("tls-cert", "TLS_CERT")
	viper.BindEnv("tls-key", "TLS_KEY")

	rootCmd = &cobra.Command{
		Use:              "horizon",
		Short:            "client-facing api server for the stellar network",
		Long:             "client-facing api server for the stellar network",
		PersistentPreRun: initApp,
		Run: func(cmd *cobra.Command, args []string) {
			app.Serve()
		},
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

	rootCmd.Flags().String(
		"ruby-horizon-url",
		"",
		"proxy yet-to-be-implemented actions through to ruby horizon server",
	)

	rootCmd.Flags().String(
		"log-level",
		"info",
		"Minimum log severity (debug, info, warn, error) to log",
	)

	rootCmd.Flags().String(
		"sentry-dsn",
		"",
		"Sentry URL to which panics and errors should be reported",
	)

	rootCmd.Flags().String(
		"loggly-token",
		"",
		"Loggly token, used to configure log forwarding to loggly",
	)

	rootCmd.Flags().String(
		"loggly-host",
		"",
		"Hostname to be added to every loggly log event",
	)

	rootCmd.Flags().String(
		"friendbot-secret",
		"",
		"Secret seed for friendbot functionality. When empty, friendbot will be disabled",
	)

	rootCmd.Flags().String(
		"tls-cert",
		"",
		"The TLS certificate file to use for securing connections to horizon",
	)

	rootCmd.Flags().String(
		"tls-key",
		"",
		"The TLS private key file to use for securing connections to horizon",
	)

	rootCmd.AddCommand(dbCmd)

	viper.BindPFlags(rootCmd.Flags())
}

func initApp(cmd *cobra.Command, args []string) {
	var err error

	if viper.GetString("db-url") == "" {
		rootCmd.Help()
		os.Exit(1)
	}

	if viper.GetString("stellar-core-db-url") == "" {
		rootCmd.Help()
		os.Exit(1)
	}

	ll, err := logrus.ParseLevel(viper.GetString("log-level"))

	if err != nil {
		log.Fatalf("Could not parse log-level: %v", viper.GetString("log-level"))
	}

	hlog.DefaultLogger.Level = ll

	cert, key := viper.GetString("tls-cert"), viper.GetString("tls-key")

	switch {
	case cert != "" && key == "":
		log.Fatal("Invalid TLS config: key not configured")
	case cert == "" && key != "":
		log.Fatal("Invalid TLS config: cert not configured")
	}

	config := horizon.Config{
		DatabaseUrl:            viper.GetString("db-url"),
		StellarCoreDatabaseUrl: viper.GetString("stellar-core-db-url"),
		StellarCoreUrl:         viper.GetString("stellar-core-url"),
		Autopump:               viper.GetBool("autopump"),
		Port:                   viper.GetInt("port"),
		RateLimit:              throttled.PerHour(viper.GetInt("per-hour-rate-limit")),
		RedisUrl:               viper.GetString("redis-url"),
		RubyHorizonUrl:         viper.GetString("ruby-horizon-url"),
		LogLevel:               ll,
		SentryDSN:              viper.GetString("sentry-dsn"),
		LogglyToken:            viper.GetString("loggly-token"),
		LogglyHost:             viper.GetString("loggly-host"),
		FriendbotSecret:        viper.GetString("friendbot-secret"),
		TLSCert:                cert,
		TLSKey:                 key,
	}

	app, err = horizon.NewApp(config)

	if err != nil {
		log.Fatal(err.Error())
	}
}
