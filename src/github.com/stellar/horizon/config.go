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
	Autopump               bool
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
	Ingest bool
}
