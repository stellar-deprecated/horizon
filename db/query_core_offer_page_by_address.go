package db

import "golang.org/x/net/context"

// CoreOfferPageByAddressQuery loads a page of active offers for the given
// address.
type CoreOfferPageByAddressQuery struct {
	SqlQuery
	PageQuery
	Address string
}

func (q CoreOfferPageByAddressQuery) Get(ctx context.Context) ([]Record, error) {
	sql := CoreOfferRecordSelect.
		Where("co.accountid = ?", q.Address).
		Limit(uint64(q.Limit))

	switch q.Order {
	case "asc":
		sql = sql.Where("co.offerid > ?", q.Cursor).OrderBy("co.offerid asc")
	case "desc":
		sql = sql.Where("co.offerid < ?", q.Cursor).OrderBy("co.offerid desc")
	}

	var records []CoreOfferRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err

}

func (q CoreOfferPageByAddressQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
