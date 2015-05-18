package log

import (
	"bytes"
	"testing"

	"golang.org/x/net/context"

	"github.com/Sirupsen/logrus"
	. "github.com/smartystreets/goconvey/convey"
)

func TestLogPackage(t *testing.T) {

	Convey("Context", t, func() {
		So(context.Background().Value(&contextKey), ShouldBeNil)
		l := logrus.New()
		ctx := Context(context.Background(), l)
		So(ctx.Value(&contextKey), ShouldEqual, l)
	})

	Convey("FromContext", t, func() {
		// defaults to the default logger
		So(FromContext(context.Background()), ShouldEqual, defaultLogger)

		// a set value overrides the default
		l := logrus.New()
		ctx := Context(context.Background(), l)
		So(FromContext(ctx), ShouldEqual, l)

		// the deepest set value is returns
		nested := logrus.New()
		nctx := Context(ctx, nested)
		So(FromContext(nctx), ShouldEqual, nested)
	})

	Convey("Logging Statements", t, func() {
		output := new(bytes.Buffer)
		defaultLogger.Out = output
		ctx := context.Background()

		Convey("defaults to warn", func() {

			Debug(context.Background(), "debug")
			Info(context.Background(), "info")
			Warn(context.Background(), "warn")

			So(output.String(), ShouldNotContainSubstring, "level=info")
			So(output.String(), ShouldNotContainSubstring, "level=debug")
			So(output.String(), ShouldContainSubstring, "level=warn")
		})

		Convey("Debug severity", func() {
			defaultLogger.Level = logrus.InfoLevel
			Debug(ctx, "Debug")
			So(output.String(), ShouldEqual, "")

			defaultLogger.Level = logrus.DebugLevel
			Debug(ctx, "Debug")
			So(output.String(), ShouldContainSubstring, "level=debug")
			So(output.String(), ShouldContainSubstring, "msg=Debug")
		})

		Convey("Info severity", func() {
			defaultLogger.Level = logrus.WarnLevel
			Debug(ctx, "foo")
			Info(ctx, "foo")
			So(output.String(), ShouldEqual, "")

			defaultLogger.Level = logrus.InfoLevel
			Info(ctx, "foo")
			So(output.String(), ShouldContainSubstring, "level=info")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Warn severity", func() {
			defaultLogger.Level = logrus.ErrorLevel
			Debug(ctx, "foo")
			Info(ctx, "foo")
			Warn(ctx, "foo")
			So(output.String(), ShouldEqual, "")

			defaultLogger.Level = logrus.WarnLevel
			Warn(ctx, "foo")
			So(output.String(), ShouldContainSubstring, "level=warn")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Error severity", func() {
			defaultLogger.Level = logrus.FatalLevel
			Debug(ctx, "foo")
			Info(ctx, "foo")
			Warn(ctx, "foo")
			Error(ctx, "foo")
			So(output.String(), ShouldEqual, "")

			defaultLogger.Level = logrus.ErrorLevel
			Error(ctx, "foo")
			So(output.String(), ShouldContainSubstring, "level=error")
			So(output.String(), ShouldContainSubstring, "msg=foo")
		})

		Convey("Panic severity", func() {
			defaultLogger.Level = logrus.PanicLevel
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

	Convey("Metrics", t, func() {
		resetMeters()
		output := new(bytes.Buffer)
		defaultLogger.Out = output
		ctx := context.Background()

		for _, meter := range Meters {

			So(meter.Count(), ShouldEqual, 0)
		}

		Debug(ctx, "foo")
		Info(ctx, "foo")
		Warn(ctx, "foo")
		Error(ctx, "foo")
		So(func() {
			Panic(ctx, "foo")
		}, ShouldPanic)

		for _, meter := range Meters {
			So(meter.Count(), ShouldEqual, 1)
		}
	})
}
