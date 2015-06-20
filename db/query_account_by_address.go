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

	if err := Get(ctx, haq, &result.HistoryAccountRecord); err != nil {
		return nil, err
	}

	if err := Get(ctx, caq, &result.CoreAccountRecord); err != nil {
		return nil, err
	}
	if err := Select(ctx, ctlq, &result.Trustlines); err != nil {
		return nil, err
	}

	return []interface{}{result}, nil
}

// IsComplete returns true when the query considers itself finished.
func (q AccountByAddressQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
