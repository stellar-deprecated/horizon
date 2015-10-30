package log

import (
	"github.com/Sirupsen/logrus"
	"github.com/go-errors/errors"
	"golang.org/x/net/context"
	// glog "log"
)

var contextKey = 0
var DefaultLogger *Entry
var DefaultMetrics *Metrics

const (
	PanicLevel = logrus.PanicLevel
	ErrorLevel = logrus.ErrorLevel
	WarnLevel  = logrus.WarnLevel
	InfoLevel  = logrus.InfoLevel
	DebugLevel = logrus.DebugLevel
)

type F logrus.Fields

func init() {
	DefaultLogger, DefaultMetrics = New()
}

// New creates a new logger according to horizon specifications.
func New() (result *Entry, m *Metrics) {
	m = NewMetrics()
	l := logrus.New()
	l.Level = logrus.WarnLevel
	l.Hooks.Add(m)

	result = &Entry{*logrus.NewEntry(l)}
	return
}

// Set establishes a new context to which the provided sub-logger is bound
func Set(parent context.Context, logger *Entry) context.Context {
	return context.WithValue(parent, &contextKey, logger)
}

// DEPRECATED: Use Ctx instead.
func FromContext(ctx context.Context) *Entry {
	return Ctx(ctx)
}

// C returns the logger bound to the provided context, otherwise
// providing the default logger.
func Ctx(ctx context.Context) *Entry {
	found := ctx.Value(&contextKey)

	if found == nil {
		return DefaultLogger
	}

	return found.(*Entry)
}

// PushContext is a helper method to derive a new context with a modified logger
// bound to it, where the logger is derived from the current value on the
// context.
func PushContext(parent context.Context, modFn func(*Entry) *Entry) context.Context {
	current := Ctx(parent)
	next := modFn(current)
	return Set(parent, next)
}

func WithField(key string, value interface{}) *Entry {
	result := DefaultLogger.WithField(key, value)
	return result
}

func WithFields(fields F) *Entry {
	return DefaultLogger.WithFields(fields)
}

func WithStack(stackProvider interface{}) *Entry {
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
