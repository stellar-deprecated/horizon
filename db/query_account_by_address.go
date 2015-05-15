package db

type AccountByAddressQuery struct {
	History SqlQuery
	Core    SqlQuery
	Address string
}

func (q AccountByAddressQuery) Get() ([]interface{}, error) {
	var result AccountRecord

	haq := HistoryAccountByAddressQuery{q.History, q.Address}
	caq := CoreAccountByAddressQuery{q.Core, q.Address}
	ctlq := CoreTrustlinesByAddressQuery{q.Core, q.Address}

	har, err := First(haq)
	if err != nil {
		return nil, err
	}
	car, err := First(caq)
	if err != nil {
		return nil, err
	}
	ctlr, err := Results(ctlq)
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

func (q AccountByAddressQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
