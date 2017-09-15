package sequence

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"testing"
	"time"
)

func TestQueue(t *testing.T) {
	ctx := test.Context()
	_ = ctx
	Convey("Queue", t, func() {
		queue := NewQueue()

		Convey("Push adds the provided channel on to the priority queue", func() {
			So(queue.Size(), ShouldEqual, 0)

			queue.Push(2)
			So(queue.Size(), ShouldEqual, 1)
			_, s := queue.head()
			So(s, ShouldEqual, 2)

			queue.Push(1)
			So(queue.Size(), ShouldEqual, 2)
			_, s = queue.head()
			So(s, ShouldEqual, 1)
		})

		Convey("Update removes sequences that are submittable or in the past", func() {
			results := []<-chan error{
				queue.Push(1),
				queue.Push(2),
				queue.Push(3),
				queue.Push(4),
			}

			queue.Update(2)

			// the update above signifies that 2 is the accounts current sequence,
			// meaning that 3 is submittable, and so only 4 should still be queued
			So(queue.Size(), ShouldEqual, 1)
			_, s := queue.head()
			So(s, ShouldEqual, 4)

			queue.Update(4)
			So(queue.Size(), ShouldEqual, 0)

			So(<-results[0], ShouldEqual, ErrBadSequence)
			So(<-results[1], ShouldEqual, ErrBadSequence)
			So(<-results[2], ShouldEqual, nil)
			So(<-results[3], ShouldEqual, ErrBadSequence)

		})

		Convey("Update clears the queue if the head has not been released within the time limit", func() {
			queue.timeout = 1 * time.Millisecond
			result := queue.Push(2)
			<-time.After(10 * time.Millisecond)
			queue.Update(0)

			So(queue.Size(), ShouldEqual, 0)
			So(<-result, ShouldEqual, ErrBadSequence)
		})
	})
}
