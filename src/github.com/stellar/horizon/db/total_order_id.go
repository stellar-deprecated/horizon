package db

import (
	"fmt"
)

//
// A TotalOrderID expressed the total order of Ledgers, Transactions and
// Operations.
//
// Operations within the stellar network have a total order, expressed by three
// pieces of information:  the ledger sequence the operation was validated in,
// the order which the operation's containing transaction was applied in
// that ledger, and the index of the operation within that parent transaction.
//
// We express this order by packing those three pieces of information into a
// single signed 64-bit number (we used a signed number for SQL compatibility).
//
// The follow diagram shows this format:
//
//    0                   1                   2                   3
//    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
//   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//   |                    Ledger Sequence Number                     |
//   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//   |     Transaction Application Order     |       Op Index        |
//   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//
// By component:
//
// Ledger Sequence: 32-bits
//
//   A complete ledger sequence number in which the operation was validated.
//
//   Expressed in network byte order.
//
// Transaction Application Order: 20-bits
//
//   The order that the transaction was applied within the ledger it was
//   validated.  Accommodates up to 1,048,575 transactions in a single ledger.
//
//   Expressed in network byte order.
//
// Operation Index: 12-bits
//
//   The index of the operation within its parent transaction. Accommodates up
//   to 4095 operations per transaction.
//
//   Expressed in network byte order.
//
//
// Note: API Clients should not be interpreting this value.  We will use it
// as an opaque paging token that clients can parrot back to us after having read
// it within a resource to page from the represented position in time.
//
// Note: This does not uniquely identify an object.  Given a ledger, it will
// share its id with its first transaction and the first operation of that
// transaction as well.  Given that this ID is only meant for ordering within a
// single type of object, the sharing of ids across object types seems
// acceptable.
//
type TotalOrderID struct {
	LedgerSequence   int32
	TransactionOrder int32
	OperationOrder   int32
}

const (
	// TotalOrderLedgerMask is the bitmask to mask out ledger sequences in a
	// TotalOrderID
	TotalOrderLedgerMask = (1 << 32) - 1
	// TotalOrderTransactionMask is the bitmask to mask out transaction indexes
	TotalOrderTransactionMask = (1 << 20) - 1
	// TotalOrderOperationMask is the bitmask to mask out operation indexes
	TotalOrderOperationMask = (1 << 12) - 1

	// TotalOrderLedgerShift is the number of bits to shift an int64 to target the
	// ledger component
	TotalOrderLedgerShift = 32
	// TotalOrderTransactionShift is the number of bits to shift an int64 to
	// target the transaction component
	TotalOrderTransactionShift = 12
	// TotalOrderOperationShift is the number of bits to shift an int64 to target
	// the operation component
	TotalOrderOperationShift = 0
)

// IncOperationOrder increments the operation order, rolling over to the next
// ledger if overflow occurs.  This allows queries to easily advance a cursor to
// the next operation.
func (id *TotalOrderID) IncOperationOrder() {
	id.OperationOrder++

	if id.OperationOrder > TotalOrderOperationMask {
		id.OperationOrder = 0
		id.LedgerSequence++
	}
}

// ToInt64 converts this struct back into an int64
func (id *TotalOrderID) ToInt64() (result int64) {

	if id.LedgerSequence < 0 {
		panic("invalid ledger sequence")
	}

	if id.TransactionOrder > TotalOrderTransactionMask {
		panic("transaction order overflow")
	}

	if id.OperationOrder > TotalOrderOperationMask {
		panic("operation order overflow")
	}

	result = result | ((int64(id.LedgerSequence) & TotalOrderLedgerMask) << TotalOrderLedgerShift)
	result = result | ((int64(id.TransactionOrder) & TotalOrderTransactionMask) << TotalOrderTransactionShift)
	result = result | ((int64(id.OperationOrder) & TotalOrderOperationMask) << TotalOrderOperationShift)
	return
}

// String returns a string representation of this id
func (id *TotalOrderID) String() string {
	return fmt.Sprintf("%d", id.ToInt64())
}

// ParseTotalOrderID parses an int64 into a TotalOrderID struct
func ParseTotalOrderID(id int64) (result TotalOrderID) {
	result.LedgerSequence = int32((id >> TotalOrderLedgerShift) & TotalOrderLedgerMask)
	result.TransactionOrder = int32((id >> TotalOrderTransactionShift) & TotalOrderTransactionMask)
	result.OperationOrder = int32((id >> TotalOrderOperationShift) & TotalOrderOperationMask)

	return
}
