package horizon

import (
	"github.com/PuerkitoBio/throttled"
	"github.com/Sirupsen/logrus"
)

// Config is the configuration for horizon.  It get's populated by the
// app's main function and is provided to NewApp.
type Config struct {
	DatabaseURL            string
	StellarCoreDatabaseURL string
	StellarCoreURL         string
	Port                   int
	RateLimit              throttled.Quota
	RedisURL               string
	LogLevel               logrus.Level
	SentryDSN              string
	LogglyHost             string
	LogglyToken            string
	FriendbotSecret        string
	// TLSCert is a path to a certificate file to use for horizon's TLS config
	TLSCert string
	// TLSKey is the path to a private key file to use for horizon's TLS config
	TLSKey string
	// Ingest is a boolean that indicates whether or not this horizon instance
	// should run the data ingestion subsystem.
	Ingest bool
	// HistoryRetentionCount represents the minimum number of ledgers worth of
	// history data to retain in the horizon database. For the purposes of
	// determining a "retention duration", each ledger roughly corresponds to 10
	// seconds of real time.
	HistoryRetentionCount uint

	// StaleThreshold represents the number of ledgers a history database may be
	// out-of-date by before horizon begins to respond with an error to history
	// requests.
	StaleThreshold uint
}
