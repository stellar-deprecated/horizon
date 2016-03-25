package db

import (
	. "github.com/smartystreets/goconvey/convey"
	tdb "github.com/stellar/horizon/test/db"
	"golang.org/x/net/context"
	"testing"
)

func TestStreaming(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	db := tdb.Horizon()

	Convey("LedgerClosePump", t, func() {

		Convey("can cancel", func() {
			pump := NewLedgerClosePump(ctx, db)
			cancel()
			_, more := <-pump
			So(more, ShouldBeFalse)
		})
	})
}
