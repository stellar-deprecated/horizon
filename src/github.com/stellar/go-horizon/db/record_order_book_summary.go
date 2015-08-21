package db

type PriceLevelRecord struct {
	Type   string
	Pricen int32
	Priced int32
	Pricef float64
	Amount int64
}

func (p *PriceLevelRecord) InvertPricef() float64 {
	return float64(p.Priced) / float64(p.Pricen)
}

// OrderBookSummaryRecord is a summary of a set of offers for a given base and
// counter currency
type OrderBookSummaryRecord []PriceLevelRecord

func (o OrderBookSummaryRecord) Asks() []PriceLevelRecord {
	result := []PriceLevelRecord{}

	for _, r := range o {
		if r.Type == "ask" {
			result = append(result, r)
		}
	}

	return result
}

func (o OrderBookSummaryRecord) Bids() []PriceLevelRecord {
	result := []PriceLevelRecord{}

	for _, r := range o {
		if r.Type == "bid" {
			result = append([]PriceLevelRecord{r}, result...)
		}
	}

	return result
}
