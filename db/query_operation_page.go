package db

import (
	"errors"

	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

const (
	// PaymentTypeFilter restricts an OperationPageQuery to return only
	// Payment and PathPayment operations
	PaymentTypeFilter = "payment"
)

// OperationPageQuery is the main query for paging through a collection
// of operations in the history database.
type OperationPageQuery struct {
	SqlQuery
	PageQuery
	AccountAddress  string
	LedgerSequence  int32
	TransactionHash string
	TypeFilter      string
}

// Get executes the query and returns the results
func (q OperationPageQuery) Get(ctx context.Context) ([]interface{}, error) {
	sql := OperationRecordSelect.
		Limit(uint64(q.Limit)).
		PlaceholderFormat(sq.Dollar).
		RunWith(q.DB)

	cursor, err := q.CursorInt64()
	if err != nil {
		return nil, err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("hop.id > ?", cursor).OrderBy("hop.id asc")
	case "desc":
		sql = sql.Where("hop.id < ?", cursor).OrderBy("hop.id desc")
	}

	err = checkOptions(
		q.AccountAddress != "",
		q.LedgerSequence != 0,
		q.TransactionHash != "",
	)

	if err != nil {
		return nil, err
	}

	// filter by ledger sequence
	if q.LedgerSequence != 0 {
		start := TotalOrderId{LedgerSequence: q.LedgerSequence}
		end := TotalOrderId{LedgerSequence: q.LedgerSequence + 1}
		sql = sql.Where("hop.id >= ? AND hop.id < ?", start.ToInt64(), end.ToInt64())
	}

	// filter by transaction hash
	if q.TransactionHash != "" {
		record, err := First(ctx, TransactionByHashQuery{q.SqlQuery, q.TransactionHash})

		if err != nil {
			return nil, err
		}

		if record == nil {
			return nil, errors.New("Bad transaction hash") //TODO: improvements
		}

		tx := record.(TransactionRecord)

		start := ParseTotalOrderId(tx.Id)
		end := start
		end.TransactionOrder++
		sql = sql.Where("hop.id >= ? AND hop.id < ?", start.ToInt64(), end.ToInt64())
	}

	// filter by account address
	if q.AccountAddress != "" {
		record, err := First(ctx, HistoryAccountByAddressQuery{q.SqlQuery, q.AccountAddress})

		if err != nil {
			return nil, err
		}

		if record == nil {
			return nil, errors.New("Bad account address") //TODO: improvements
		}

		account := record.(HistoryAccountRecord)
		sql = sql.
			Join("history_operation_participants hopp ON hopp.history_operation_id = hop.id").
			Where("hopp.history_account_id = ?", account.Id)
	}

	if q.TypeFilter == PaymentTypeFilter {
		// TODO: pull constants from go-stellar-base when it exists
		sql = sql.Where("hop.type IN (1,2)")
	}

	var records []OperationRecord
	err = q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q OperationPageQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
