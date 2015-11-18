package db

import (
	"fmt"
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"math"
	"testing"
)

func TestTotalOrderID(t *testing.T) {
	ledger := int64(4294967296) // ledger sequence 1
	tx := int64(4096)           // tx index 1
	op := int64(1)              // op index 1

	Convey("TotalOrderID.ToInt64", t, func() {
		Convey("accomodates 12-bits of precision for the operation", func() {
			So((&TotalOrderID{0, 0, 1}).ToInt64(), ShouldEqual, 1)
			So((&TotalOrderID{0, 0, 4095}).ToInt64(), ShouldEqual, 4095)
			So(func() { (&TotalOrderID{0, 0, 4096}).ToInt64() }, ShouldPanic)
		})

		Convey("accomodates 20-bits of precision for the transaction", func() {
			So((&TotalOrderID{0, 1, 0}).ToInt64(), ShouldEqual, 4096)
			So((&TotalOrderID{0, 1048575, 0}).ToInt64(), ShouldEqual, 4294963200)
			So(func() { (&TotalOrderID{0, 1048576, 0}).ToInt64() }, ShouldPanic)
		})

		Convey("accomodates 32-bits of precision for the ledger", func() {
			So((&TotalOrderID{1, 0, 0}).ToInt64(), ShouldEqual, 4294967296)
			So((&TotalOrderID{math.MaxInt32, 0, 0}).ToInt64(), ShouldEqual, 9223372032559808512)
			So(func() { (&TotalOrderID{-1, 0, 0}).ToInt64() }, ShouldPanic)
			So(func() { (&TotalOrderID{math.MinInt32, 0, 0}).ToInt64() }, ShouldPanic)
		})

		Convey("works as expected", func() {
			So((&TotalOrderID{1, 1, 1}).ToInt64(), ShouldEqual, ledger+tx+op)
			So((&TotalOrderID{1, 1, 0}).ToInt64(), ShouldEqual, ledger+tx)
			So((&TotalOrderID{1, 0, 1}).ToInt64(), ShouldEqual, ledger+op)
			So((&TotalOrderID{1, 0, 0}).ToInt64(), ShouldEqual, ledger)
			So((&TotalOrderID{0, 1, 0}).ToInt64(), ShouldEqual, tx)
			So((&TotalOrderID{0, 0, 1}).ToInt64(), ShouldEqual, op)
			So((&TotalOrderID{0, 0, 0}).ToInt64(), ShouldEqual, 0)
		})
	})

	Convey("ParseTotalOrderID", t, func() {
		toid := ParseTotalOrderID(ledger + tx + op)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 1)
		So(toid.OperationOrder, ShouldEqual, 1)

		toid = ParseTotalOrderID(ledger + tx)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 1)
		So(toid.OperationOrder, ShouldEqual, 0)

		toid = ParseTotalOrderID(ledger + op)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 0)
		So(toid.OperationOrder, ShouldEqual, 1)

		toid = ParseTotalOrderID(ledger)
		So(toid.LedgerSequence, ShouldEqual, 1)
		So(toid.TransactionOrder, ShouldEqual, 0)
		So(toid.OperationOrder, ShouldEqual, 0)

		toid = ParseTotalOrderID(tx)
		So(toid.LedgerSequence, ShouldEqual, 0)
		So(toid.TransactionOrder, ShouldEqual, 1)
		So(toid.OperationOrder, ShouldEqual, 0)

		toid = ParseTotalOrderID(op)
		So(toid.LedgerSequence, ShouldEqual, 0)
		So(toid.TransactionOrder, ShouldEqual, 0)
		So(toid.OperationOrder, ShouldEqual, 1)
	})

	Convey("IncOperationOrder", t, func() {
		tid := TotalOrderID{0, 0, 0}
		tid.IncOperationOrder()
		So(tid.OperationOrder, ShouldEqual, 1)
		tid.OperationOrder = TotalOrderOperationMask
		tid.IncOperationOrder()
		So(tid.OperationOrder, ShouldEqual, 0)
		So(tid.LedgerSequence, ShouldEqual, 1)
	})
}

func ExampleParseTotalOrderID() {
	toid := ParseTotalOrderID(12884910080)
	fmt.Printf("ledger:%d, tx:%d, op:%d", toid.LedgerSequence, toid.TransactionOrder, toid.OperationOrder)
	// Output: ledger:3, tx:2, op:0
}
