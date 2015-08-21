package db

// PriceLevelRecord is a collapsed view of multiple offers at the same price that
// contains the summed amount from all the member offers. Used by OrderBookSummaryRecord
type PriceLevelRecord struct {
	Type   string
	Pricen int32
	Priced int32
	Pricef float64
	Amount int64
}

// InvertPricef returns the inverted price of the price-level, i.e. what the price would be if you were
// viewing the price level from the other side of the bid/ask dichotomy.
func (p *PriceLevelRecord) InvertPricef() float64 {
	return float64(p.Priced) / float64(p.Pricen)
}

// OrderBookSummaryRecord is a summary of a set of offers for a given base and
// counter currency
type OrderBookSummaryRecord []PriceLevelRecord

// Asks filters the summary into a slice of PriceLevelRecords where the type is 'ask'
func (o OrderBookSummaryRecord) Asks() []PriceLevelRecord {
	result := []PriceLevelRecord{}

	for _, r := range o {
		if r.Type == "ask" {
			result = append(result, r)
		}
	}

	return result
}

// Bids filters the summary into a slice of PriceLevelRecords where the type is 'bid'
func (o OrderBookSummaryRecord) Bids() []PriceLevelRecord {
	result := []PriceLevelRecord{}

	for _, r := range o {
		if r.Type == "bid" {
			result = append([]PriceLevelRecord{r}, result...)
		}
	}

	return result
}
