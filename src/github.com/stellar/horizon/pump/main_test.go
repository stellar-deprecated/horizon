package pump

import (
	"testing"
	"time"

	. "github.com/smartystreets/goconvey/convey"
)

func TestMain(t *testing.T) {

	Convey("Pump", t, func() {
		t := make(chan struct{})
		p := NewPump(t)

		trigger := func() {
			t <- struct{}{}
			<-time.After(1 * time.Millisecond)
		}

		trigger()

		r1 := p.Subscribe()
		r2 := p.Subscribe()
		<-time.After(1 * time.Millisecond)

		So(len(r1), ShouldEqual, 0)
		So(len(r1), ShouldEqual, 0)

		trigger()
		So(len(r1), ShouldEqual, 1)
		So(len(r2), ShouldEqual, 1)

		<-r1
		<-r2

		p.Unsubscribe(r2)
		_, more := <-r2
		So(more, ShouldBeFalse)

		trigger()
		So(len(r1), ShouldEqual, 1)
		<-r1

	})
}
