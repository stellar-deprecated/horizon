package db

import (
	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/db2"
	"golang.org/x/net/context"
)

// CoreOfferPageByAddressQuery loads a page of active offers for the given
// address.
type CoreOfferPageByAddressQuery struct {
	SqlQuery
	db2.PageQuery
	Address string
}

func (q CoreOfferPageByAddressQuery) Select(ctx context.Context, dest interface{}) error {
	sql := sq.Select("co.*").
		From("offers co").
		Where("co.sellerid = ?", q.Address).
		Limit(uint64(q.Limit))

	cursor, err := q.CursorInt64()
	if err != nil {
		return err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("co.offerid > ?", cursor).OrderBy("co.offerid asc")
	case "desc":
		sql = sql.Where("co.offerid < ?", cursor).OrderBy("co.offerid desc")
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
