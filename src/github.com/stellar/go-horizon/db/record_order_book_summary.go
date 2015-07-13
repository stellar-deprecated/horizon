package db

// OrderBookSummaryRecord is a summary of a set of offers for a given base and
// counter currency
type OrderBookSummaryRecord struct {
	Bids []CoreOfferRecord
	Asks []CoreOfferRecord
}
