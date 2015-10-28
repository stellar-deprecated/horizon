package log

import (
	"github.com/Sirupsen/logrus"
	"github.com/go-errors/errors"
	"golang.org/x/net/context"
)

var contextKey = 0
var DefaultLogger *Logger
var DefaultMetrics *Metrics

type F logrus.Fields

func init() {
	DefaultLogger, DefaultMetrics = New()
}

// New creates a new logger according to horizon specifications.
func New() (result *Logger, m *Metrics) {
	m = NewMetrics()
	l := logrus.New()
	l.Level = logrus.WarnLevel
	l.Hooks.Add(m)

	result = (*Logger)(logrus.NewEntry(l))
	return
}

// Set establishes a new context to which the provided sub-logger is bound
func Set(parent context.Context, logger *Logger) context.Context {
	return context.WithValue(parent, &contextKey, logger)
}

// DEPRECATED: Use Ctx instead.
func FromContext(ctx context.Context) *Logger {
	return Ctx(ctx)
}

// C returns the logger bound to the provided context, otherwise
// providing the default logger.
func Ctx(ctx context.Context) *Logger {
	found := ctx.Value(&contextKey)

	if found == nil {
		return DefaultLogger
	}

	return found.(*Logger)
}

// PushContext is a helper method to derive a new context with a modified logger
// bound to it, where the logger is derived from the current value on the
// context.
func PushContext(parent context.Context, modFn func(*Logger) *Logger) context.Context {
	current := Ctx(parent)
	next := modFn(current)
	return Set(parent, next)
}

func WithField(key string, value interface{}) *Logger {
	return DefaultLogger.WithField(key, value)
}

func WithFields(fields F) *Logger {
	return DefaultLogger.WithFields(fields)
}

func WithStack(stackProvider interface{}) *Logger {
	stack := "unknown"

	if stackProvider, ok := stackProvider.(*errors.Error); ok {
		stack = string(stackProvider.Stack())
	}

	return WithField("stack", stack)
}

// ===== Delegations =====

// Debugf logs a message at the debug severity.
func Debugf(format string, args ...interface{}) {
	DefaultLogger.Debugf(format, args...)
}

// Debug logs a message at the debug severity.
func Debug(args ...interface{}) {
	DefaultLogger.Debug(args...)
}

// Infof logs a message at the Info severity.
func Infof(format string, args ...interface{}) {
	DefaultLogger.Infof(format, args...)
}

// Info logs a message at the Info severity.
func Info(args ...interface{}) {
	DefaultLogger.Info(args...)
}

// Warnf logs a message at the Warn severity.
func Warnf(format string, args ...interface{}) {
	DefaultLogger.Warnf(format, args...)
}

// Warn logs a message at the Warn severity.
func Warn(args ...interface{}) {
	DefaultLogger.Warn(args...)
}

// Errorf logs a message at the Error severity.
func Errorf(format string, args ...interface{}) {
	DefaultLogger.Errorf(format, args...)
}

// Error logs a message at the Error severity.
func Error(args ...interface{}) {
	DefaultLogger.Error(args...)
}

// Panicf logs a message at the Panic severity.
func Panicf(format string, args ...interface{}) {
	DefaultLogger.Panicf(format, args...)
}

// Panic logs a message at the Panic severity.
func Panic(args ...interface{}) {
	DefaultLogger.Panic(args...)
}
