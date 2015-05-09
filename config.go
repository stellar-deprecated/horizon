package horizon

import (
	"github.com/PuerkitoBio/throttled"
)

type Config struct {
	DatabaseUrl            string
	StellarCoreDatabaseUrl string
	Port                   int
	Autopump               bool
	RateLimit              throttled.Quota
	RedisUrl               string
}
