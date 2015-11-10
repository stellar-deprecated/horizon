// Package resource contains the type definitions for all of horizons
// response resources.
package resource

import (
	"github.com/jagregory/halgo"
)

// AccountResource is the summary of an account
type Account struct {
	halgo.Links
	ID                   string            `json:"id"`
	PagingToken          string            `json:"paging_token"`
	Address              string            `json:"address"`
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

// Balance represents an account's holdings for a single currency type
type Balance struct {
	Type    string `json:"asset_type"`
	Balance string `json:"balance"`
	// additional trustline data
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"issuer,omitempty"`
	Limit  string `json:"limit,omitempty"`
}

// Signer represents one of an account's signers.
type Signer struct {
	Address string `json:"address"`
	Weight  int32  `json:"weight"`
}
