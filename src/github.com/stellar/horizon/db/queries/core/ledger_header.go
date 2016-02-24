package core

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// Select implements the db.Query interface
func (q *LedgerHeaderBySequence) Select(ctx context.Context, dest interface{}) error {
	sql := sq.Select("clh.*").
		From("ledgerheaders clh").
		Limit(1).
		Where("clh.ledgerseq = ?", q.Sequence)

	return q.DB.Select(ctx, sql, dest)
}
