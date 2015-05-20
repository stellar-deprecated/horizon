package db

import sq "github.com/lann/squirrel"

// CoreOfferRecordSelect is a sql fragment to help select form queries that
// select into a CoreOfferRecord
var CoreOfferRecordSelect = sq.Select(
	"co.accountid",
	"co.offerid",
).From("offers co")

// CoreOfferRecord is row of data from the `offers` table from stellar-core
type CoreOfferRecord struct {
	Accountid string
	Offerid   int64
}
