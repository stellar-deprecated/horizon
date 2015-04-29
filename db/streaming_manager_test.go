package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"golang.org/x/net/context"
	"testing"
)

func TestStreamingManager(t *testing.T) {
	Convey("Streaming Manager", t, func() {
		manager := newStreamManager()
		go manager.Run()
		defer manager.Shutdown()

		Convey("Adds queries properly", func() {
			query := mockDumpQuery{}
			_ = manager.Add(context.Background(), query)
			So(len(manager.queries), ShouldEqual, 1)
		})

		Convey("Streams results", func() {
			query := mockDumpQuery{}
			stream := manager.Add(context.Background(), query)
			So(len(manager.queries), ShouldEqual, 1)

			go manager.Pump()

			record, _ := <-stream.Get()
			So(record.Err, ShouldBeNil)
			So(record.Record.(string), ShouldEqual, "hello")

			record, _ = <-stream.Get()
			So(record.Err, ShouldBeNil)
			So(record.Record.(string), ShouldEqual, "world")

			record, _ = <-stream.Get()
			So(record.Err, ShouldBeNil)
			So(record.Record.(string), ShouldEqual, "from")

			record, _ = <-stream.Get()
			So(record.Err, ShouldBeNil)
			So(record.Record.(string), ShouldEqual, "go")

			_, ok := <-stream.Get()
			So(ok, ShouldBeFalse)

			Convey("Removes finished queries", func() {
				var queryCount int
				manager.Do(func() { queryCount = len(manager.queries) })
				So(queryCount, ShouldEqual, 0)
			})
		})
	})
}
