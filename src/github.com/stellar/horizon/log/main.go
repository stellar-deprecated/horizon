package log

import (
	"runtime"
	"strings"

	"github.com/Sirupsen/logrus"
	"golang.org/x/net/context"
)

var contextKey = 0
var defaultLogger *logrus.Entry
var defaultMetrics *Metrics

// New creates a new logger according to horizon specifications.
func New() (result *logrus.Entry, m *Metrics) {
	m = NewMetrics()
	l := logrus.New()
	l.Level = logrus.WarnLevel
	l.Hooks.Add(m)

	result = logrus.NewEntry(l)
	return
}

// Context establishes a new context to which the provided sub-logger is bound
func Context(parent context.Context, entry *logrus.Entry) context.Context {
	return context.WithValue(parent, &contextKey, entry)
}

// PushContext is a helper method to derive a new context with a modified logger
// bound to it, where the logger is derived from the current value on the
// context.
func PushContext(parent context.Context, modFn func(entry *logrus.Entry) *logrus.Entry) context.Context {
	current := FromContext(parent)
	next := modFn(current)
	return Context(parent, next)
}

func WithField(ctx context.Context, key string, value interface{}) *logrus.Entry {
	return FromContext(ctx).WithField(key, value)
}

func WithFields(ctx context.Context, fields logrus.Fields) *logrus.Entry {
	return FromContext(ctx).WithFields(fields)
}

// FromContext retrieves the current registered logger from the provided
// context, defaulting to a process-wide default if the context does not have
// an associated logger.
func FromContext(ctx context.Context) *logrus.Entry {
	found := ctx.Value(&contextKey)

	if found == nil {
		return defaultLogger
	}

	return found.(*logrus.Entry)
}

// SetDefaultLoggerLevel sets the logging level for the default logger
func SetDefaultLoggerLevel(level logrus.Level) {
	defaultLogger.Logger.Level = level
}

func init() {
	defaultLogger, defaultMetrics = New()
}

// ===== Delegations =====

// Debugf logs a message at the debug severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Debugf(ctx context.Context, format string, args ...interface{}) {
	FromContext(ctx).Debugf(format, args...)
}

// Debug logs a message at the debug severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Debug(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Debug(args...)
}

// Debugln logs a message at the debug severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Debugln(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Debugln(args...)
}

// Infof logs a message at the Info severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Infof(ctx context.Context, format string, args ...interface{}) {
	FromContext(ctx).Infof(format, args...)
}

// Info logs a message at the Info severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Info(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Info(args...)
}

// Infoln logs a message at the Info severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Infoln(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Infoln(args...)
}

// Warnf logs a message at the Warn severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Warnf(ctx context.Context, format string, args ...interface{}) {
	FromContext(ctx).Warnf(format, args...)
}

// Warn logs a message at the Warn severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Warn(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Warn(args...)
}

// Warnln logs a message at the Warn severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Warnln(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Warnln(args...)
}

// Errorf logs a message at the Error severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Errorf(ctx context.Context, format string, args ...interface{}) {
	addSourceLocations(FromContext(ctx)).Errorf(format, args...)
}

// Error logs a message at the Error severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Error(ctx context.Context, args ...interface{}) {
	addSourceLocations(FromContext(ctx)).Error(args...)
}

// Errorln logs a message at the Error severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Errorln(ctx context.Context, args ...interface{}) {
	addSourceLocations(FromContext(ctx)).Errorln(args...)
}

// Panicf logs a message at the Panic severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Panicf(ctx context.Context, format string, args ...interface{}) {
	FromContext(ctx).Panicf(format, args...)
}

// Panic logs a message at the Panic severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Panic(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Panic(args...)
}

// Panicln logs a message at the Panic severity.  Delegates to the
// logrus.Logger bound to the provided context.
func Panicln(ctx context.Context, args ...interface{}) {
	FromContext(ctx).Panicln(args...)
}

func addSourceLocations(e *logrus.Entry) *logrus.Entry {
	_, file, line, _ := runtime.Caller(2)

	// attempt to strip the project prefix
	parts := strings.SplitN(file, "horizon/", 2)
	if len(parts) == 2 {
		file = parts[1]
	}

	return e.WithFields(logrus.Fields{
		"file": file,
		"line": line,
	})
}
