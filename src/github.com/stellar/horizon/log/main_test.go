package log

import (
	"bytes"
	"errors"
	"testing"

	"golang.org/x/net/context"

	"github.com/Sirupsen/logrus"
	ge "github.com/go-errors/errors"
	. "github.com/smartystreets/goconvey/convey"
)

func TestLogPackage(t *testing.T) {

	Convey("Set", t, func() {
		So(context.Background().Value(&contextKey), ShouldBeNil)
		l, _ := New()
		ctx := Set(context.Background(), l)
		So(ctx.Value(&contextKey), ShouldEqual, l)
	})

	Convey("Ctx", t, func() {
		// defaults to the default logger
		So(Ctx(context.Background()), ShouldEqual, DefaultLogger)

		// a set value overrides the default
		l, _ := New()

		ctx := Set(context.Background(), l)
		So(Ctx(ctx), ShouldEqual, l)

		// the deepest set value is returns
		nested, _ := New()
		nctx := Set(ctx, nested)
		So(Ctx(nctx), ShouldEqual, nested)
	})

	Convey("PushContext", t, func() {
		output := new(bytes.Buffer)
		l, _ := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
		l.Logger.Out = output
		ctx := Set(context.Background(), l.WithField("foo", "bar"))

		Ctx(ctx).Warn("hello")
		So(output.String(), ShouldContainSubstring, "foo=bar")
		So(output.String(), ShouldNotContainSubstring, "foo=baz")

		ctx = PushContext(ctx, func(logger *Logger) *Logger {
			return logger.WithField("foo", "baz")
		})

		Ctx(ctx).Warn("hello")
		So(output.String(), ShouldContainSubstring, "foo=baz")
	})

	Convey("Logging Statements", t, func() {
		output := new(bytes.Buffer)
		l, _ := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
		l.Logger.Out = output

		Convey("defaults to warn", func() {

			l.Debug("debug")
			l.Info("info")
			l.Warn("warn")

			So(output.String(), ShouldNotContainSubstring, "level=info")
			So(output.String(), ShouldNotContainSubstring, "level=debug")
			So(output.String(), ShouldContainSubstring, "level=warn")
		})

		Convey("Debug severity", func() {
			l.Logger.Level = logrus.InfoLevel
			l.Debug("Debug")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.DebugLevel
			l.Debug("Debug")
			So(output.String(), ShouldContainSubstring, "level=debug")
			So(output.String(), ShouldContainSubstring, "msg=Debug")
		})

		Convey("Info severity", func() {
			l.Logger.Level = logrus.WarnLevel
			l.Debug("foo")
			l.Info("foo")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.InfoLevel
			l.Info("foo")
			So(output.String(), ShouldContainSubstring, "level=info")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Warn severity", func() {
			l.Logger.Level = logrus.ErrorLevel
			l.Debug("foo")
			l.Info("foo")
			l.Warn("foo")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.WarnLevel
			l.Warn("foo")
			So(output.String(), ShouldContainSubstring, "level=warn")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Error severity", func() {
			l.Logger.Level = logrus.FatalLevel
			l.Debug("foo")
			l.Info("foo")
			l.Warn("foo")
			l.Error("foo")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.ErrorLevel
			l.Error("foo")
			So(output.String(), ShouldContainSubstring, "level=error")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Panic severity", func() {
			l.Logger.Level = logrus.PanicLevel
			l.Debug("foo")
			l.Info("foo")
			l.Warn("foo")
			l.Error("foo")
			So(output.String(), ShouldEqual, "")

			So(func() {
				l.Panic("foo")
			}, ShouldPanic)

			So(output.String(), ShouldContainSubstring, "level=panic")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})
	})

	Convey("WithStack", t, func() {
		output := new(bytes.Buffer)
		l, _ := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
		l.Logger.Out = output

		Convey("Adds stack=unknown when the provided err has not stack info", func() {
			l.WithStack(errors.New("broken")).Error("test")
			So(output.String(), ShouldContainSubstring, "stack=unknown")
		})
		Convey("Adds the stack properly if a go-errors.Error is provided", func() {
			err := ge.New("broken")
			l.WithStack(err).Error("test")
			// simply ensure that the line creating the above error is in the log
			So(output.String(), ShouldContainSubstring, "main_test.go:")
		})
	})

	Convey("Metrics", t, func() {
		output := new(bytes.Buffer)
		l, m := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
		l.Logger.Level = logrus.DebugLevel
		l.Logger.Out = output

		for _, meter := range *m {
			So(meter.Count(), ShouldEqual, 0)
		}

		l.Debug("foo")
		l.Info("foo")
		l.Warn("foo")
		l.Error("foo")
		So(func() {
			l.Panic("foo")
		}, ShouldPanic)

		for _, meter := range *m {
			So(meter.Count(), ShouldEqual, 1)
		}
	})
}
