package db

// OrderBookSummaryPriceLevelRecord is a collapsed view of multiple offers at the same price that
// contains the summed amount from all the member offers. Used by OrderBookSummaryRecord
type OrderBookSummaryPriceLevelRecord struct {
	Type string `db:"type"`
	PriceLevelRecord
}

// OrderBookSummaryRecord is a summary of a set of offers for a given base and
// counter currency
type OrderBookSummaryRecord []OrderBookSummaryPriceLevelRecord

// Asks filters the summary into a slice of PriceLevelRecords where the type is 'ask'
func (o OrderBookSummaryRecord) Asks() []OrderBookSummaryPriceLevelRecord {
	return o.filter("ask", false)
}

// Bids filters the summary into a slice of PriceLevelRecords where the type is 'bid'
func (o OrderBookSummaryRecord) Bids() []OrderBookSummaryPriceLevelRecord {
	return o.filter("bid", true)
}

func (o OrderBookSummaryRecord) filter(typ string, prepend bool) []OrderBookSummaryPriceLevelRecord {
	result := []OrderBookSummaryPriceLevelRecord{}

	for _, r := range o {
		if r.Type != typ {
			continue
		}

		if prepend {
			head := []OrderBookSummaryPriceLevelRecord{r}
			result = append(head, result...)
		} else {
			result = append(result, r)
		}
	}

	return result
}
