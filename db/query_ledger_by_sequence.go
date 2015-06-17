package db

import "golang.org/x/net/context"

type LedgerBySequenceQuery struct {
	SqlQuery
	Sequence int32
}

func (q LedgerBySequenceQuery) Get(ctx context.Context) ([]Record, error) {
	sql := LedgerRecordSelect.Where("sequence = ?", q.Sequence).Limit(1)

	var records []LedgerRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (l LedgerBySequenceQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
