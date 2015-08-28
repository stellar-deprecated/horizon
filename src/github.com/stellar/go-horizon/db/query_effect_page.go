package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
	"math"
)

// EffectPageQuery is the main query for paging through a collection
// of operations in the history database.
type EffectPageQuery struct {
	SqlQuery
	PageQuery
	AccountAddress  string
	LedgerSequence  int32
	TransactionHash string
	OperationID     int64
}

// Select executes the query and returns the results
func (q EffectPageQuery) Select(ctx context.Context, dest interface{}) (err error) {
	sql := EffectRecordSelect.
		Limit(uint64(q.Limit)).
		PlaceholderFormat(sq.Dollar).
		RunWith(q.DB)

	cursorOp, cursorOrd, err := q.CursorInt64Pair(DefaultPairSep)
	if err != nil {
		return
	}

	if cursorOrd > math.MaxInt32 {
		cursorOrd = math.MaxInt32
	}

	switch q.Order {
	case "asc":
		sql = sql.
			Where(`(
					 heff.history_operation_id > ? 
				OR (
							heff.history_operation_id = ?
					AND heff.order > ?
				))`, cursorOp, cursorOp, cursorOrd).
			OrderBy("heff.history_operation_id asc, heff.order asc")
	case "desc":
		sql = sql.
			Where(`(
					 heff.history_operation_id < ? 
				OR (
							heff.history_operation_id = ?
					AND heff.order < ?
				))`, cursorOp, cursorOp, cursorOrd).
			OrderBy("heff.history_operation_id desc, heff.order desc")
	}

	err = checkOptions(
		q.AccountAddress != "",
		q.LedgerSequence != 0,
		q.TransactionHash != "",
		q.OperationID != 0,
	)

	if err != nil {
		return
	}

	// filter by ledger sequence
	if q.LedgerSequence != 0 {
		start := TotalOrderId{LedgerSequence: q.LedgerSequence}
		end := TotalOrderId{LedgerSequence: q.LedgerSequence + 1}
		sql = sql.Where(
			"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
			start.ToInt64(),
			end.ToInt64(),
		)
	}

	// filter by transaction hash
	if q.TransactionHash != "" {
		var tx TransactionRecord
		err = Get(ctx, TransactionByHashQuery{q.SqlQuery, q.TransactionHash}, &tx)

		if err != nil {
			return
		}

		start := ParseTotalOrderId(tx.Id)
		end := start
		end.TransactionOrder++
		sql = sql.Where(
			"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
			start.ToInt64(),
			end.ToInt64(),
		)
	}

	// filter by account address
	if q.AccountAddress != "" {
		var account HistoryAccountRecord
		err = Get(ctx, HistoryAccountByAddressQuery{q.SqlQuery, q.AccountAddress}, &account)

		if err != nil {
			return
		}

		sql = sql.Where("heff.history_account_id = ?", account.Id)
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
