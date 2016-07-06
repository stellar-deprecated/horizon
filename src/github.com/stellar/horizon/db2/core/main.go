// Package core contains database record definitions useable for
// reading rows from a Stellar Core db
package core

import (
	"github.com/guregu/null"
	"github.com/stellar/go-stellar-base/strkey"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db2"
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

// AccountData is a row of data from the `accountdata` table
type AccountData struct {
	Accountid string
	Key       string `db:"dataname"`
	Value     string `db:"datavalue"`
}

// LedgerHeader is row of data from the `ledgerheaders` table
type LedgerHeader struct {
	LedgerHash     string           `db:"ledgerhash"`
	PrevHash       string           `db:"prevhash"`
	BucketListHash string           `db:"bucketlisthash"`
	CloseTime      int64            `db:"closetime"`
	Sequence       uint32           `db:"ledgerseq"`
	Data           xdr.LedgerHeader `db:"data"`
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

// Q is a helper struct on which to hang common queries against a stellar
// core database.
type Q struct {
	*db2.Repo
}

// PriceLevel represents an aggregation of offers to trade at a certain
// price.
type PriceLevel struct {
	Pricen int32   `db:"pricen"`
	Priced int32   `db:"priced"`
	Pricef float64 `db:"pricef"`
	Amount int64   `db:"amount"`
}

// SequenceProvider implements `txsub.SequenceProvider`
type SequenceProvider struct {
	Q *Q
}

// Signer is a row of data from the `signers` table from stellar-core
type Signer struct {
	Accountid string
	Publickey string
	Weight    int32
}

// Transaction is row of data from the `txhistory` table from stellar-core
type Transaction struct {
	TransactionHash string                    `db:"txid"`
	LedgerSequence  int32                     `db:"ledgerseq"`
	Index           int32                     `db:"txindex"`
	Envelope        xdr.TransactionEnvelope   `db:"txbody"`
	Result          xdr.TransactionResultPair `db:"txresult"`
	ResultMeta      xdr.TransactionMeta       `db:"txmeta"`
}

// TransactionFee is row of data from the `txfeehistory` table from stellar-core
type TransactionFee struct {
	TransactionHash string                 `db:"txid"`
	LedgerSequence  int32                  `db:"ledgerseq"`
	Index           int32                  `db:"txindex"`
	Changes         xdr.LedgerEntryChanges `db:"txchanges"`
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

// AssetFromDB produces an xdr.Asset by combining the constituent type, code and
// issuer, as often retrieved from the DB in 3 separate columns.
func AssetFromDB(typ xdr.AssetType, code string, issuer string) (result xdr.Asset, err error) {
	switch typ {
	case xdr.AssetTypeAssetTypeNative:
		result, err = xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)
	case xdr.AssetTypeAssetTypeCreditAlphanum4:
		var (
			an      xdr.AssetAlphaNum4
			decoded []byte
			pkey    xdr.Uint256
		)

		copy(an.AssetCode[:], []byte(code))
		decoded, err = strkey.Decode(strkey.VersionByteAccountID, issuer)
		if err != nil {
			return
		}

		copy(pkey[:], decoded)
		an.Issuer, err = xdr.NewAccountId(xdr.CryptoKeyTypeKeyTypeEd25519, pkey)
		if err != nil {
			return
		}
		result, err = xdr.NewAsset(xdr.AssetTypeAssetTypeCreditAlphanum4, an)
	case xdr.AssetTypeAssetTypeCreditAlphanum12:
		var (
			an      xdr.AssetAlphaNum12
			decoded []byte
			pkey    xdr.Uint256
		)

		copy(an.AssetCode[:], []byte(code))
		decoded, err = strkey.Decode(strkey.VersionByteAccountID, issuer)
		if err != nil {
			return
		}

		copy(pkey[:], decoded)
		an.Issuer, err = xdr.NewAccountId(xdr.CryptoKeyTypeKeyTypeEd25519, pkey)
		if err != nil {
			return
		}
		result, err = xdr.NewAsset(xdr.AssetTypeAssetTypeCreditAlphanum12, an)
	}

	return
}

// ElderLedger represents the oldest "ingestable" ledger known to the
// stellar-core database this ingestion system is communicating with.  Horizon,
// which wants to operate on a contiguous range of ledger data (i.e. free from
// gaps) uses the elder ledger to start importing in the case of an empty
// database.
//
// Due to the design of stellar-core, ledger 1 will _always_ be in the database,
// even when configured to catchup minimally, so we cannot simply take
// MIN(ledgerseq). Instead, we can find whether or not 1 is the elder ledger by
// checking for the presence of ledger 2.
func (q *Q) ElderLedger(dest *int32) error {
	var found bool
	err := q.GetRaw(&found, `
		SELECT CASE WHEN EXISTS (
		    SELECT *
		    FROM ledgerheaders
		    WHERE ledgerseq = 2
		)
		THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT) END
	`)

	if err != nil {
		return err
	}

	// if ledger 2 is present, use it 1 as the elder ledger (since 1 is guaranteed
	// to be present)
	if found {
		*dest = 1
		return nil
	}

	err = q.GetRaw(dest, `
		SELECT COALESCE(MIN(ledgerseq), 0)
		FROM ledgerheaders
		WHERE ledgerseq > 2
	`)

	return err
}

// LatestLedger loads the latest known ledger
func (q *Q) LatestLedger(dest interface{}) error {
	return q.GetRaw(dest, `SELECT COALESCE(MAX(ledgerseq), 0) FROM ledgerheaders`)
}
