package txsub

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/pkg/test"
	"testing"
	"time"
)

func TestDefaultSubmissionList(t *testing.T) {
	ctx := test.Context()

	Convey("submissionList (The default OpenSubmissionList implementation)", t, func() {
		list := NewDefaultSubmissionList()
		realList := list.(*submissionList)
		hashes := []string{
			"0000000000000000000000000000000000000000000000000000000000000000",
			"0000000000000000000000000000000000000000000000000000000000000001",
		}

		listeners := []chan Result{
			make(chan Result, 1),
			make(chan Result, 1),
		}

		Convey("Add()", func() {
			Convey("adds an entry to the submission list when a new hash is used", func() {
				list.Add(ctx, hashes[0], listeners[0])
				sub := realList.submissions[hashes[0]]
				So(sub.Hash, ShouldEqual, hashes[0])
				So(sub.SubmittedAt, ShouldHappenWithin, 1*time.Second, time.Now())

				// drop the send side of the channel by casting to listener
				var l Listener = listeners[0]
				So(sub.Listeners[0], ShouldEqual, l)
			})

			Convey("adds an listener to an existing entry when a hash is used with a new listener", func() {
				list.Add(ctx, hashes[0], listeners[0])
				sub := realList.submissions[hashes[0]]
				st := sub.SubmittedAt
				<-time.After(20 * time.Millisecond)
				list.Add(ctx, hashes[0], listeners[1])

				// increases the size of the listener
				So(len(sub.Listeners), ShouldEqual, 2)
				// doesn't update the submitted at time
				So(st == sub.SubmittedAt, ShouldEqual, true)
			})

			Convey("panics when the listener is not buffered", func() {
				So(func() { list.Add(ctx, hashes[0], make(Listener)) }, ShouldPanic)
			})

			Convey("errors when the provided hash is not 64-bytes", func() {
				err := list.Add(ctx, "123", listeners[0])
				So(err, ShouldNotBeNil)
			})
		})

		Convey("Finish()", func() {
			list.Add(ctx, hashes[0], listeners[0])
			list.Add(ctx, hashes[0], listeners[1])
			r := Result{
				Hash: hashes[0],
			}
			list.Finish(ctx, r)

			Convey("writes to every listener", func() {
				r1, ok1 := <-listeners[0]
				So(r1, ShouldResemble, r)
				So(ok1, ShouldBeTrue)

				r2, ok2 := <-listeners[1]
				So(r2, ShouldResemble, r)
				So(ok2, ShouldBeTrue)
			})

			Convey("removes the entry", func() {
				_, ok := realList.submissions[hashes[0]]
				So(ok, ShouldBeFalse)
			})

			Convey("closes every listener", func() {
				_, _ = <-listeners[0]
				_, more := <-listeners[0]
				So(more, ShouldBeFalse)

				_, _ = <-listeners[1]
				_, more = <-listeners[1]
				So(more, ShouldBeFalse)
			})

			Convey("works when the noone is waiting for the result", func() {
				err := list.Finish(ctx, r)
				So(err, ShouldBeNil)
			})

		})

		Convey("Clean()", func() {
			list.Add(ctx, hashes[0], listeners[0])
			<-time.After(200 * time.Millisecond)
			list.Add(ctx, hashes[1], listeners[1])
			left, err := list.Clean(ctx, 200*time.Millisecond)

			So(err, ShouldBeNil)
			So(left, ShouldEqual, 1)

			Convey("removes submissions older than the maxAge provided", func() {
				_, ok := realList.submissions[hashes[0]]
				So(ok, ShouldBeFalse)
			})

			Convey("leaves submissions that are younger than the maxAge provided", func() {
				_, ok := realList.submissions[hashes[1]]
				So(ok, ShouldBeTrue)
			})

			Convey("closes any cleaned listeners", func() {
				So(len(listeners[0]), ShouldEqual, 1)
				<-listeners[0]
				select {
				case _, stillOpen := <-listeners[0]:
					So(stillOpen, ShouldBeFalse)
				default:
					panic("cleaned listener is still open")
				}
			})
		})

		Convey("Pending() works as expected", func() {
			So(len(list.Pending(ctx)), ShouldEqual, 0)
			list.Add(ctx, hashes[0], listeners[0])
			So(len(list.Pending(ctx)), ShouldEqual, 1)
			list.Add(ctx, hashes[1], listeners[1])
			So(len(list.Pending(ctx)), ShouldEqual, 2)
		})
	})
}
