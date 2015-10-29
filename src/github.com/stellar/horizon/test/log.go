package test

import (
	"github.com/Sirupsen/logrus"
	"github.com/stellar/horizon/log"
)

var testLogger *log.Entry

func init() {
	testLogger, _ = log.New()
	testLogger.Entry.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
	testLogger.Entry.Logger.Level = logrus.DebugLevel
}
