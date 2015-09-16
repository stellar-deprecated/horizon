package db

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"golang.org/x/net/context"
	"testing"
	"time"
)

func TestStreaming(t *testing.T) {
	ctx, log := test.ContextWithLogBuffer()
	ctx, cancel := context.WithCancel(ctx)
	db := test.OpenDatabase(test.DatabaseUrl())

	Convey("LedgerClosePump", t, func() {

		Convey("can cancel", func() {
			pump := NewLedgerClosePump(ctx, db)
			cancel()
			_, more := <-pump
			So(more, ShouldBeFalse)
			So(log.String(), ShouldContainSubstring, "canceling")
		})
	})
}
