package log

import (
	"github.com/Sirupsen/logrus"
	"github.com/go-errors/errors"
)

type Logger logrus.Entry

func (l *Logger) WithField(key string, value interface{}) *Logger {
	sl := (*logrus.Entry)(l).WithField(key, value)
	return (*Logger)(sl)
}

func (l *Logger) WithFields(fields F) *Logger {
	sl := (*logrus.Entry)(l).WithFields(logrus.Fields(fields))
	return (*Logger)(sl)
}

func (l *Logger) WithStack(stackProvider interface{}) *Logger {
	stack := "unknown"

	if stackProvider, ok := stackProvider.(*errors.Error); ok {
		stack = string(stackProvider.Stack())
	}

	return l.WithField("stack", stack)
}

// Debugf logs a message at the debug severity.
func (l *Logger) Debugf(format string, args ...interface{}) {
	(*logrus.Entry)(l).Debugf(format, args...)
}

// Debug logs a message at the debug severity.
func (l *Logger) Debug(args ...interface{}) {
	(*logrus.Entry)(l).Debug(args...)
}

// Infof logs a message at the Info severity.
func (l *Logger) Infof(format string, args ...interface{}) {
	(*logrus.Entry)(l).Infof(format, args...)
}

// Info logs a message at the Info severity.
func (l *Logger) Info(args ...interface{}) {
	(*logrus.Entry)(l).Info(args...)
}

// Warnf logs a message at the Warn severity.
func (l *Logger) Warnf(format string, args ...interface{}) {
	(*logrus.Entry)(l).Warnf(format, args...)
}

// Warn logs a message at the Warn severity.
func (l *Logger) Warn(args ...interface{}) {
	(*logrus.Entry)(l).Warn(args...)
}

// Errorf logs a message at the Error severity.
func (l *Logger) Errorf(format string, args ...interface{}) {
	(*logrus.Entry)(l).Errorf(format, args...)
}

// Error logs a message at the Error severity.
func (l *Logger) Error(args ...interface{}) {
	(*logrus.Entry)(l).Error(args...)
}

// Panicf logs a message at the Panic severity.
func (l *Logger) Panicf(format string, args ...interface{}) {
	(*logrus.Entry)(l).Panicf(format, args...)
}

// Panic logs a message at the Panic severity.
func (l *Logger) Panic(args ...interface{}) {
	(*logrus.Entry)(l).Panic(args...)
}
