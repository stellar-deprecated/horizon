package log

import (
	"os"
	"time"

	"github.com/Sirupsen/logrus"
	"github.com/segmentio/go-loggly"
)

// LogglyHook sends logs to loggly
type LogglyHook struct {
	client *loggly.Client
	host   string
}

// NewLogglyHook creates a new hook
func NewLogglyHook(token string) *LogglyHook {
	client := loggly.New(token, "horizon")
	host, err := os.Hostname()

	if err != nil {
		panic("couldn't get hostname")
	}

	return &LogglyHook{
		client: client,
		host:   host,
	}
}

func (hook *LogglyHook) Fire(entry *logrus.Entry) error {
	logglyMessage := loggly.Message{
		"timestamp": entry.Time.UTC().Format(time.RFC3339Nano),
		"severity":  entry.Level.String(),
		"type":      entry.Message,
		"host":      hook.host,
	}

	return hook.client.Send(logglyMessage)
}

func (hook *LogglyHook) Flush() {
	hook.client.Flush()
}

func (hook *LogglyHook) Levels() []logrus.Level {
	return []logrus.Level{
		logrus.PanicLevel,
		logrus.FatalLevel,
		logrus.ErrorLevel,
		logrus.WarnLevel,
		logrus.InfoLevel,
		logrus.DebugLevel,
	}
}
