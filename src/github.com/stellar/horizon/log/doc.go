// Package log provides the logging facilities used for horizon.
//
// You may notice that this package does not expose the "Fatal" family of
// logging functions:  this is intentional.  This package is specifically geared
// to logging within the context of an http server, and our chosen path for
// responding to "Of my god something is horribly wrong" within the context
// of an HTTP request is to panic on that request.
//
// **Be Careful** this package mostly deals with exposing *logrus.Entry objects
// as loggers, rather than *logrus.Logger.  This allows horizon middlewares
// to append contextual fields to logging subsystem using WithField and
// WithFields.  Unfortunately, this can lead to some strange bugs if you expect
// a logrus.Logger instance, most notably around setting log level.
package log
