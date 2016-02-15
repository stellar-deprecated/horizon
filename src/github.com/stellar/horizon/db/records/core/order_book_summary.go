package core

// Asks filters the summary into a slice of PriceLevelRecords where the type is 'ask'
func (o *OrderBookSummary) Asks() []OrderBookSummaryPriceLevel {
	return o.filter("ask", false)
}

// Bids filters the summary into a slice of PriceLevelRecords where the type is 'bid'
func (o *OrderBookSummary) Bids() []OrderBookSummaryPriceLevel {
	return o.filter("bid", true)
}

func (o *OrderBookSummary) filter(typ string, prepend bool) []OrderBookSummaryPriceLevel {
	result := []OrderBookSummaryPriceLevel{}

	for _, r := range *o {
		if r.Type != typ {
			continue
		}

		if prepend {
			head := []OrderBookSummaryPriceLevel{r}
			result = append(head, result...)
		} else {
			result = append(result, r)
		}
	}

	return result
}
