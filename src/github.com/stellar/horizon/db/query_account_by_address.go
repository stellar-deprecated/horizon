package db

import (
	"golang.org/x/net/context"
)

// AccountByAddressQuery represents a query that retrieves a composite
// of the CoreAccount and the HistoryAccount associated with an address.
type AccountByAddressQuery struct {
	History SqlQuery
	Core    SqlQuery
	Address string
}

func (q AccountByAddressQuery) Select(ctx context.Context, dest interface{}) error {
	var result AccountRecord
	var cq Query

	cq = HistoryAccountByAddressQuery{q.History, q.Address}
	err := Get(ctx, cq, &result.HistoryAccountRecord)
	if err != nil {
		return err
	}

	cq = CoreAccountByAddressQuery{q.Core, q.Address}
	err = Get(ctx, cq, &result.Account)
	if err != nil {
		return err
	}

	cq = CoreTrustlinesByAddressQuery{q.Core, q.Address}
	err = Select(ctx, cq, &result.Trustlines)
	if err != nil {
		return err
	}

	cq = CoreSignersByAddressQuery{q.Core, q.Address}
	err = Select(ctx, cq, &result.Signers)
	if err != nil {
		return err
	}
	setOn([]AccountRecord{result}, dest)
	return nil
}
