package sequence

import (
	. "github.com/smartystreets/goconvey/convey"
	"testing"
)

func TestManager(t *testing.T) {
	Convey("Manager", t, func() {
		mgr := NewManager()

		Convey("Push", func() {
			mgr.Push("1", 2)
			mgr.Push("1", 2)
			mgr.Push("1", 3)
			mgr.Push("2", 2)

			So(mgr.Size(), ShouldEqual, 4)
			So(mgr.queues["1"].Size(), ShouldEqual, 3)
			So(mgr.queues["2"].Size(), ShouldEqual, 1)
		})

		Convey("Update", func() {
			results := []<-chan error{
				mgr.Push("1", 2),
				mgr.Push("1", 3),
				mgr.Push("2", 2),
			}

			mgr.Update(map[string]uint64{
				"1": 1,
				"2": 1,
			})

			So(mgr.Size(), ShouldEqual, 1)
			_, ok := mgr.queues["2"]
			So(ok, ShouldBeFalse)

			So(<-results[0], ShouldEqual, nil)
			So(<-results[2], ShouldEqual, nil)
			So(len(results[1]), ShouldEqual, 0)
		})
	})
}
