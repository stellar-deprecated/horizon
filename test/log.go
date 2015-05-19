package test

import (
	"github.com/Sirupsen/logrus"
	"github.com/stellar/go-horizon/log"
)

var testLogger *logrus.Entry

func init() {
	testLogger, _ = log.New()
	testLogger.Logger.Level = logrus.DebugLevel
}
