package test

import (
	"github.com/Sirupsen/logrus"
	"github.com/stellar/horizon/log"
)

var testLogger *log.Logger

func init() {
	testLogger, _ = log.New()
	testLogger.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
	testLogger.Logger.Level = logrus.DebugLevel
}
