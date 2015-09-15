package db

//
// A TotalOrderId expressed the total order of Ledgers, Transactions and
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
type TotalOrderId struct {
	LedgerSequence   int32
	TransactionOrder int32
	OperationOrder   int32
}

const (
	TotalOrderLedgerMask      = (1 << 32) - 1
	TotalOrderTransactionMask = (1 << 20) - 1
	TotalOrderOperationMask   = (1 << 12) - 1

	TotalOrderLedgerShift      = 32
	TotalOrderTransactionShift = 12
	TotalOrderOperationShift   = 0
)

func (id TotalOrderId) ToInt64() (result int64) {

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

func ParseTotalOrderId(id int64) (result TotalOrderId) {
	result.LedgerSequence = int32((id >> TotalOrderLedgerShift) & TotalOrderLedgerMask)
	result.TransactionOrder = int32((id >> TotalOrderTransactionShift) & TotalOrderTransactionMask)
	result.OperationOrder = int32((id >> TotalOrderOperationShift) & TotalOrderOperationMask)

	return
}
