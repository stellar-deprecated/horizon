package log

import (
	"github.com/Sirupsen/logrus"
	"github.com/rcrowley/go-metrics"
	"golang.org/x/net/context"
)

var contextKey = 0
var defaultLogger *logrus.Logger

// Meters provides access to the individual metrics for the logging subsystem.
var Meters map[logrus.Level]metrics.Meter

// Context establishes a new context to which the provided logger is bound
func Context(parent context.Context, logger *logrus.Logger) context.Context {
	return context.WithValue(parent, &contextKey, logger)
}

// FromContext retrieves the current registered logger from the provided
// context, defaulting to a process-wide default if the context does not have
// an associated logger.
func FromContext(ctx context.Context) *logrus.Logger {
	found := ctx.Value(&contextKey)

	if found == nil {
		return defaultLogger
	}

	return found.(*logrus.Logger)
}

// SetDefaultLoggerLevel sets the logging level for the default logger
func SetDefaultLoggerLevel(level logrus.Level) {
	defaultLogger.Level = level
}

func resetMeters() {
	Meters = map[logrus.Level]metrics.Meter{
		logrus.DebugLevel: metrics.NewMeter(),
		logrus.InfoLevel:  metrics.NewMeter(),
		logrus.WarnLevel:  metrics.NewMeter(),
		logrus.ErrorLevel: metrics.NewMeter(),
		logrus.PanicLevel: metrics.NewMeter(),
	}
}

func init() {
	defaultLogger = logrus.New()
	defaultLogger.Level = logrus.WarnLevel
	resetMeters()
}

// ===== Delegations =====

// Debugf logs a message at the debug severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Debugf(ctx context.Context, format string, args ...interface{}) {
	Meters[logrus.DebugLevel].Mark(1)
	FromContext(ctx).Debugf(format, args...)
}

// Debug logs a message at the debug severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Debug(ctx context.Context, args ...interface{}) {
	Meters[logrus.DebugLevel].Mark(1)
	FromContext(ctx).Debug(args...)
}

// Debugln logs a message at the debug severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Debugln(ctx context.Context, args ...interface{}) {
	Meters[logrus.DebugLevel].Mark(1)
	FromContext(ctx).Debugln(args...)
}

// Infof logs a message at the Info severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Infof(ctx context.Context, format string, args ...interface{}) {
	Meters[logrus.InfoLevel].Mark(1)
	FromContext(ctx).Infof(format, args...)
}

// Info logs a message at the Info severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Info(ctx context.Context, args ...interface{}) {
	Meters[logrus.InfoLevel].Mark(1)
	FromContext(ctx).Info(args...)
}

// Infoln logs a message at the Info severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Infoln(ctx context.Context, args ...interface{}) {
	Meters[logrus.InfoLevel].Mark(1)
	FromContext(ctx).Infoln(args...)
}

// Warnf logs a message at the Warn severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Warnf(ctx context.Context, format string, args ...interface{}) {
	Meters[logrus.WarnLevel].Mark(1)
	FromContext(ctx).Warnf(format, args...)
}

// Warn logs a message at the Warn severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Warn(ctx context.Context, args ...interface{}) {
	Meters[logrus.WarnLevel].Mark(1)
	FromContext(ctx).Warn(args...)
}

// Warnln logs a message at the Warn severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Warnln(ctx context.Context, args ...interface{}) {
	Meters[logrus.WarnLevel].Mark(1)
	FromContext(ctx).Warnln(args...)
}

// Errorf logs a message at the Error severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Errorf(ctx context.Context, format string, args ...interface{}) {
	Meters[logrus.ErrorLevel].Mark(1)
	FromContext(ctx).Errorf(format, args...)
}

// Error logs a message at the Error severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Error(ctx context.Context, args ...interface{}) {
	Meters[logrus.ErrorLevel].Mark(1)
	FromContext(ctx).Error(args...)
}

// Errorln logs a message at the Error severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Errorln(ctx context.Context, args ...interface{}) {
	Meters[logrus.ErrorLevel].Mark(1)
	FromContext(ctx).Errorln(args...)
}

// Panicf logs a message at the Panic severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Panicf(ctx context.Context, format string, args ...interface{}) {
	Meters[logrus.PanicLevel].Mark(1)
	FromContext(ctx).Panicf(format, args...)
}

// Panic logs a message at the Panic severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Panic(ctx context.Context, args ...interface{}) {
	Meters[logrus.PanicLevel].Mark(1)
	FromContext(ctx).Panic(args...)
}

// Panicln logs a message at the Panic severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Panicln(ctx context.Context, args ...interface{}) {
	Meters[logrus.PanicLevel].Mark(1)
	FromContext(ctx).Panicln(args...)
}
