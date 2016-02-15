// Package core contains database record definitions useable for
// reading rows from a Stellar Core db
package core

import (
	"github.com/guregu/null"
	"github.com/stellar/go-stellar-base/xdr"
)

// Account is a row of data from the `accounts` table
type Account struct {
	Accountid     string
	Balance       xdr.Int64
	Seqnum        string
	Numsubentries int32
	Inflationdest null.String
	HomeDomain    null.String
	Thresholds    xdr.Thresholds
	Flags         xdr.AccountFlags
}

// LedgerHeader is row of data from the `ledgerheaders` table
type LedgerHeader struct {
	Hash           string `db:"ledgerhash"`
	PrevHash       string `db:"prevhash"`
	BucketListHash string `db:"bucketlisthash"`
	Sequence       uint32 `db:"ledgerseq"`
	EnvelopeXDR    string `db:"txbody"`
	ResultXDR      string `db:"txresult"`
	ResultMetaXDR  string `db:"txmeta"`
}

// Offer is row of data from the `offers` table from stellar-core
type Offer struct {
	SellerID string `db:"sellerid"`
	OfferID  int64  `db:"offerid"`

	SellingAssetType xdr.AssetType `db:"sellingassettype"`
	SellingAssetCode null.String   `db:"sellingassetcode"`
	SellingIssuer    null.String   `db:"sellingissuer"`

	BuyingAssetType xdr.AssetType `db:"buyingassettype"`
	BuyingAssetCode null.String   `db:"buyingassetcode"`
	BuyingIssuer    null.String   `db:"buyingissuer"`

	Amount       xdr.Int64 `db:"amount"`
	Pricen       int32     `db:"pricen"`
	Priced       int32     `db:"priced"`
	Price        float64   `db:"price"`
	Flags        int32     `db:"flags"`
	Lastmodified int32     `db:"lastmodified"`
}

// OrderBookSummaryPriceLevel is a collapsed view of multiple offers at the same price that
// contains the summed amount from all the member offers. Used by OrderBookSummary
type OrderBookSummaryPriceLevel struct {
	Type string `db:"type"`
	PriceLevel
}

// OrderBookSummary is a summary of a set of offers for a given base and
// counter currency
type OrderBookSummary []OrderBookSummaryPriceLevel

// PriceLevel represents an aggregation of offers to trade at a certain
// price.
type PriceLevel struct {
	Pricen int32   `db:"pricen"`
	Priced int32   `db:"priced"`
	Pricef float64 `db:"pricef"`
	Amount int64   `db:"amount"`
}

// Signer is a row of data from the `signers` table from stellar-core
type Signer struct {
	Accountid string
	Publickey string
	Weight    int32
}

// Transaction is row of data from the `txhistory` table from stellar-core
type Transaction struct {
	TransactionHash string `db:"txid"`
	LedgerSequence  int32  `db:"ledgerseq"`
	Index           int32  `db:"txindex"`
	EnvelopeXDR     string `db:"txbody"`
	ResultXDR       string `db:"txresult"`
	ResultMetaXDR   string `db:"txmeta"`
}

// Trustline is a row of data from the `trustlines` table from stellar-core
type Trustline struct {
	Accountid string
	Assettype xdr.AssetType
	Issuer    string
	Assetcode string
	Tlimit    xdr.Int64
	Balance   xdr.Int64
	Flags     int32
}
