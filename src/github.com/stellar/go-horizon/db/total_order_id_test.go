package db

import (
	"fmt"
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"math"
	"testing"
)

func TestTotalOrderId(t *testing.T) {
	ledger := int64(4294967296) // ledger sequence 1
	tx := int64(4096)           // tx index 1
	op := int64(1)              // op index 1

	Convey("TotalOrderId.ToInt64", t, func() {
		Convey("accomodates 12-bits of precision for the operation", func() {
			So(TotalOrderId{0, 0, 1}.ToInt64(), ShouldEqual, 1)
			So(TotalOrderId{0, 0, 4095}.ToInt64(), ShouldEqual, 4095)
			So(func() { TotalOrderId{0, 0, 4096}.ToInt64() }, ShouldPanic)
		})

		Convey("accomodates 20-bits of precision for the transaction", func() {
			So(TotalOrderId{0, 1, 0}.ToInt64(), ShouldEqual, 4096)
			So(TotalOrderId{0, 1048575, 0}.ToInt64(), ShouldEqual, 4294963200)
			So(func() { TotalOrderId{0, 1048576, 0}.ToInt64() }, ShouldPanic)
		})

		Convey("accomodates 32-bits of precision for the ledger", func() {
			So(TotalOrderId{1, 0, 0}.ToInt64(), ShouldEqual, 4294967296)
			So(TotalOrderId{math.MaxInt32, 0, 0}.ToInt64(), ShouldEqual, 9223372032559808512)
			So(func() { TotalOrderId{-1, 0, 0}.ToInt64() }, ShouldPanic)
			So(func() { TotalOrderId{math.MinInt32, 0, 0}.ToInt64() }, ShouldPanic)
		})

		Convey("works as expected", func() {
			So(TotalOrderId{1, 1, 1}.ToInt64(), ShouldEqual, ledger+tx+op)
			So(TotalOrderId{1, 1, 0}.ToInt64(), ShouldEqual, ledger+tx)
			So(TotalOrderId{1, 0, 1}.ToInt64(), ShouldEqual, ledger+op)
			So(TotalOrderId{1, 0, 0}.ToInt64(), ShouldEqual, ledger)
			So(TotalOrderId{0, 1, 0}.ToInt64(), ShouldEqual, tx)
			So(TotalOrderId{0, 0, 1}.ToInt64(), ShouldEqual, op)
			So(TotalOrderId{0, 0, 0}.ToInt64(), ShouldEqual, 0)
		})
	})

	Convey("ParseTotalOrderId", t, func() {
		toid := ParseTotalOrderId(ledger + tx + op)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 1)
		So(toid.OperationOrder, ShouldEqual, 1)

		toid = ParseTotalOrderId(ledger + tx)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 1)
		So(toid.OperationOrder, ShouldEqual, 0)

		toid = ParseTotalOrderId(ledger + op)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 0)
		So(toid.OperationOrder, ShouldEqual, 1)

		toid = ParseTotalOrderId(ledger)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 0)
		So(toid.OperationOrder, ShouldEqual, 0)

		toid = ParseTotalOrderId(tx)
		So(toid.LedgerSequence, ShouldEqual, 0)
		So(toid.TransactionOrder, ShouldEqual, 1)
		So(toid.OperationOrder, ShouldEqual, 0)

		toid = ParseTotalOrderId(op)
		So(toid.LedgerSequence, ShouldEqual, 0)
		So(toid.TransactionOrder, ShouldEqual, 0)
		So(toid.OperationOrder, ShouldEqual, 1)
	})
}

func ExampleParseTotalOrderId() {
	toid := ParseTotalOrderId(12884910080)
	fmt.Printf("ledger:%d, tx:%d, op:%d", toid.LedgerSequence, toid.TransactionOrder, toid.OperationOrder)
	// Output: ledger:3, tx:2, op:0
}
