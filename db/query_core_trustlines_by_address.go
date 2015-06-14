package db

import "golang.org/x/net/context"

type CoreTrustlinesByAddressQuery struct {
	SqlQuery
	Address string
}

func (q CoreTrustlinesByAddressQuery) Get(ctx context.Context) ([]Record, error) {
	sql := CoreTrustlineRecordSelect.Where("accountid = ?", q.Address)

	var records []CoreTrustlineRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q CoreTrustlinesByAddressQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	// this query is not stream compatible.  If we've returned any results
	// consider the query complete
	return alreadyDelivered > 0
}
