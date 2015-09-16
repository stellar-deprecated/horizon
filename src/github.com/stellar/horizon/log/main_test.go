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

	Convey("Context", t, func() {
		So(context.Background().Value(&contextKey), ShouldBeNil)
		l, _ := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true

		ctx := Context(context.Background(), l)
		So(ctx.Value(&contextKey), ShouldEqual, l)
	})

	Convey("FromContext", t, func() {
		// defaults to the default logger
		So(FromContext(context.Background()), ShouldEqual, defaultLogger)

		// a set value overrides the default
		l, _ := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true

		ctx := Context(context.Background(), l)
		So(FromContext(ctx), ShouldEqual, l)

		// the deepest set value is returns
		nested, _ := New()
		nested.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
		nctx := Context(ctx, nested)
		So(FromContext(nctx), ShouldEqual, nested)
	})

	Convey("PushContext", t, func() {
		output := new(bytes.Buffer)
		l, _ := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
		l.Logger.Out = output
		ctx := Context(context.Background(), l.WithField("foo", "bar"))

		Warn(ctx, "hello")
		So(output.String(), ShouldContainSubstring, "foo=bar")
		So(output.String(), ShouldNotContainSubstring, "foo=baz")

		ctx = PushContext(ctx, func(entry *logrus.Entry) *logrus.Entry {
			return entry.WithField("foo", "baz")
		})

		Warn(ctx, "hello")
		So(output.String(), ShouldContainSubstring, "foo=baz")
	})

	Convey("Logging Statements", t, func() {
		output := new(bytes.Buffer)
		l, _ := New()
		l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
		l.Logger.Out = output
		ctx := Context(context.Background(), l)

		Convey("defaults to warn", func() {

			Debug(ctx, "debug")
			Info(ctx, "info")
			Warn(ctx, "warn")

			So(output.String(), ShouldNotContainSubstring, "level=info")
			So(output.String(), ShouldNotContainSubstring, "level=debug")
			So(output.String(), ShouldContainSubstring, "level=warn")
		})

		Convey("Debug severity", func() {
			l.Logger.Level = logrus.InfoLevel
			Debug(ctx, "Debug")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.DebugLevel
			Debug(ctx, "Debug")
			So(output.String(), ShouldContainSubstring, "level=debug")
			So(output.String(), ShouldContainSubstring, "msg=Debug")
		})

		Convey("Info severity", func() {
			l.Logger.Level = logrus.WarnLevel
			Debug(ctx, "foo")
			Info(ctx, "foo")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.InfoLevel
			Info(ctx, "foo")
			So(output.String(), ShouldContainSubstring, "level=info")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Warn severity", func() {
			l.Logger.Level = logrus.ErrorLevel
			Debug(ctx, "foo")
			Info(ctx, "foo")
			Warn(ctx, "foo")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.WarnLevel
			Warn(ctx, "foo")
			So(output.String(), ShouldContainSubstring, "level=warn")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Error severity", func() {
			l.Logger.Level = logrus.FatalLevel
			Debug(ctx, "foo")
			Info(ctx, "foo")
			Warn(ctx, "foo")
			Error(ctx, "foo")
			So(output.String(), ShouldEqual, "")

			l.Logger.Level = logrus.ErrorLevel
			Error(ctx, "foo")
			So(output.String(), ShouldContainSubstring, "level=error")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Panic severity", func() {
			l.Logger.Level = logrus.PanicLevel
			Debug(ctx, "foo")
			Info(ctx, "foo")
			Warn(ctx, "foo")
			Error(ctx, "foo")
			So(output.String(), ShouldEqual, "")

			So(func() {
				Panic(ctx, "foo")
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
		ctx := Context(context.Background(), l)

		Convey("Adds stack=unknown when the provided err has not stack info", func() {
			WithStack(ctx, errors.New("broken")).Error("test")
			So(output.String(), ShouldContainSubstring, "stack=unknown")
		})
		Convey("Adds the stack properly if a go-errors.Error is provided", func() {
			err := ge.New("broken")
			WithStack(ctx, err).Error("test")
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

		ctx := Context(context.Background(), l)

		for _, meter := range *m {
			So(meter.Count(), ShouldEqual, 0)
		}

		Debug(ctx, "foo")
		Info(ctx, "foo")
		Warn(ctx, "foo")
		Error(ctx, "foo")
		So(func() {
			Panic(ctx, "foo")
		}, ShouldPanic)

		for _, meter := range *m {
			So(meter.Count(), ShouldEqual, 1)
		}
	})
}
