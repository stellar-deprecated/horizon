// Package resource contains the type definitions for all of horizons
// response resources.
package resource

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/resource/base"
	"github.com/stellar/horizon/resource/effects"
	"github.com/stellar/horizon/resource/operations"
	"time"
)

// AccountResource is the summary of an account
type Account struct {
	Links struct {
		Self         hal.Link `json:"self"`
		Transactions hal.Link `json:"transactions"`
		Operations   hal.Link `json:"operations"`
		Payments     hal.Link `json:"payments"`
		Effects      hal.Link `json:"effects"`
		Offers       hal.Link `json:"offers"`
	} `json:"_links"`

	HistoryAccount
	Sequence             int64             `json:"sequence"`
	SubentryCount        int32             `json:"subentry_count"`
	InflationDestination string            `json:"inflation_destination,omitempty"`
	HomeDomain           string            `json:"home_domain,omitempty"`
	Thresholds           AccountThresholds `json:"thresholds"`
	Flags                AccountFlags      `json:"flags"`
	Balances             []Balance         `json:"balances"`
	Signers              []Signer          `json:"signers"`
}

// AccountFlags represents the state of an account's flags
type AccountFlags struct {
	AuthRequired  bool `json:"auth_required"`
	AuthRevocable bool `json:"auth_revocable"`
}

// AccountThresholds represents an accounts "thresholds", the numerical values
// needed to satisfy the authorization of a given operation.
type AccountThresholds struct {
	LowThreshold  byte `json:"low_threshold"`
	MedThreshold  byte `json:"med_threshold"`
	HighThreshold byte `json:"high_threshold"`
}

type Asset base.Asset

// Balance represents an account's holdings for a single currency type
type Balance struct {
	Balance string `json:"balance"`
	Limit   string `json:"limit,omitempty"`
	base.Asset
}

// HistoryAccount is a simple resource, used for the account collection
// actions.  It provides only the TotalOrderId of the account and its address.
type HistoryAccount struct {
	ID      string `json:"id"`
	PT      string `json:"paging_token"`
	Address string `json:"address"`
}

type Ledger struct {
	Links struct {
		Self         hal.Link `json:"self"`
		Transactions hal.Link `json:"transactions"`
		Operations   hal.Link `json:"operations"`
		Payments     hal.Link `json:"payments"`
		Effects      hal.Link `json:"effects"`
	} `json:"_links"`
	ID               string    `json:"id"`
	PT               string    `json:"paging_token"`
	Hash             string    `json:"hash"`
	PrevHash         string    `json:"prev_hash,omitempty"`
	Sequence         int32     `json:"sequence"`
	TransactionCount int32     `json:"transaction_count"`
	OperationCount   int32     `json:"operation_count"`
	ClosedAt         time.Time `json:"closed_at"`
	TotalCoins       string    `json:"total_coins"`
	FeePool          string    `json:"fee_pool"`
	BaseFee          int32     `json:"base_fee"`
	BaseReserve      string    `json:"base_reserve"`
	MaxTxSetSize     int32     `json:"max_tx_set_size"`
}

// Offer is the display form of an offer to trade currency.
type Offer struct {
	Links struct {
		Self       hal.Link `json:"self"`
		OfferMaker hal.Link `json:"offer_maker"`
	} `json:"_links"`

	ID      int64      `json:"id"`
	PT      string     `json:"paging_token"`
	Seller  string     `json:"seller"`
	Selling base.Asset `json:"selling"`
	Buying  base.Asset `json:"buying"`
	Amount  string     `json:"amount"`
	PriceR  base.Price `json:"price_r"`
	Price   string     `json:"price"`
}

type Price base.Price

// Signer represents one of an account's signers.
type Signer struct {
	Address string `json:"address"`
	Weight  int32  `json:"weight"`
}

// NewEffect returns a resource of the appropriate sub-type for the provided
// effect record.
func NewEffect(row db.EffectRecord) (result hal.Pageable, err error) {
	return effects.New(row)
}

// NewOperation returns a resource of the appropriate sub-type for the provided
// operation record.
func NewOperation(row db.OperationRecord) (result hal.Pageable, err error) {
	return operations.New(row)
}
