package db

import "golang.org/x/net/context"

// AccountByAddressQuery represents a query that retrieves a composite
// of the CoreAccount and the HistoryAccount associated with an address.
type AccountByAddressQuery struct {
	History SqlQuery
	Core    SqlQuery
	Address string
}

// Get executes the query, returning any results found
func (q AccountByAddressQuery) Get(ctx context.Context) ([]interface{}, error) {
	var result AccountRecord

	haq := HistoryAccountByAddressQuery{q.History, q.Address}
	caq := CoreAccountByAddressQuery{q.Core, q.Address}
	ctlq := CoreTrustlinesByAddressQuery{q.Core, q.Address}

	har, err := First(ctx, haq)
	if err != nil {
		return nil, err
	}
	car, err := First(ctx, caq)
	if err != nil {
		return nil, err
	}
	ctlr, err := Results(ctx, ctlq)
	if err != nil {
		return nil, err
	}

	if car == nil || har == nil {
		return nil, nil
	}

	result.HistoryAccountRecord = har.(HistoryAccountRecord)
	result.CoreAccountRecord = car.(CoreAccountRecord)
	result.Trustlines = make([]CoreTrustlineRecord, len(ctlr))

	for i, tl := range ctlr {
		result.Trustlines[i] = tl.(CoreTrustlineRecord)
	}

	return []interface{}{result}, nil
}

// IsComplete returns true when the query considers itself finished.
func (q AccountByAddressQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
