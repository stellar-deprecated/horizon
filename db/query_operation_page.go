package db

import (
	"errors"
	sq "github.com/lann/squirrel"
)

type OperationPageQuery struct {
	SqlQuery
	PageQuery
	AccountAddress  string
	LedgerSequence  int32
	TransactionHash string
}

func (q OperationPageQuery) Get() (results []interface{}, err error) {
	sql := OperationRecordSelect.
		Limit(uint64(q.Limit)).
		PlaceholderFormat(sq.Dollar).
		RunWith(q.DB)

	switch q.Order {
	case "asc":
		sql = sql.Where("hop.id > ?", q.Cursor).OrderBy("hop.id asc")
	case "desc":
		sql = sql.Where("hop.id < ?", q.Cursor).OrderBy("hop.id desc")
	}

	err = checkOptions(
		q.AccountAddress != "",
		q.LedgerSequence != 0,
		q.TransactionHash != "",
	)

	if err != nil {
		return
	}

	// filter by ledger sequence
	if q.LedgerSequence != 0 {
		start := TotalOrderId{LedgerSequence: q.LedgerSequence}
		end := TotalOrderId{LedgerSequence: q.LedgerSequence + 1}
		sql = sql.Where("hop.id >= ? AND hop.id < ?", start.ToInt64(), end.ToInt64())
	}

	// filter by transaction hash
	if q.TransactionHash != "" {
		var record interface{}
		record, err = First(TransactionByHashQuery{q.SqlQuery, q.TransactionHash})

		if err != nil {
			return
		}

		if record == nil {
			err = errors.New("Bad transaction hash") //TODO: improvements
			return
		}

		tx := record.(TransactionRecord)

		start := ParseTotalOrderId(tx.Id)
		end := start
		end.TransactionOrder++
		sql = sql.Where("hop.id >= ? AND hop.id < ?", start.ToInt64(), end.ToInt64())
	}

	// filter by account address
	if q.AccountAddress != "" {
		//TODO
	}

	var records []OperationRecord
	err = q.SqlQuery.Select(sql, &records)
	results = makeResult(records)
	return
}

func (q OperationPageQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
