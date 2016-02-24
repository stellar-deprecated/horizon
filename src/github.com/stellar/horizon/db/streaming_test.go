package db

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"golang.org/x/net/context"
	"testing"
)

func TestStreaming(t *testing.T) {
	ctx := test.Context()
	ctx, cancel := context.WithCancel(ctx)
	db := test.OpenDatabase(test.DatabaseURL())

	Convey("LedgerClosePump", t, func() {

		Convey("can cancel", func() {
			pump := NewLedgerClosePump(ctx, db)
			cancel()
			_, more := <-pump
			So(more, ShouldBeFalse)
		})
	})
}
