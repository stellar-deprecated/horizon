package horizon

import (
	"fmt"

	"github.com/guregu/null"
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

// AccountResource is the summary of an account
type AccountResource struct {
	halgo.Links
	ID                    string             `json:"id"`
	PagingToken           string             `json:"paging_token"`
	Address               string             `json:"address"`
	Sequence              int64              `json:"sequence"`
	SubentryCount         int32              `json:"subentry_count"`
	InflationDestination  null.String        `json:"inflation_destination"`
	HomeDomain            null.String        `json:"home_domain"`
	Thresholds            ThresholdsResource `json:"thresholds"`
	Flags                 FlagsResource      `json:"flags"`
	Balances              []BalanceResource  `json:"balances"`
	Signers               []SignerResource   `json:"signers"`
}

// BalanceResource represents an accounts holdings for a single currency type
type BalanceResource struct {
	Type    string `json:"asset_type"`
	Balance string `json:"balance"`
	// additional trustline data
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"issuer,omitempty"`
	Limit  string `json:"limit,omitempty"`
}

type SignerResource struct {
	Address string `json:"address"`
	Weight  int32  `json:"weight"`
}

type ThresholdsResource struct {
	LowThreshold  byte `json:"low_threshold"`
	MedThreshold  byte `json:"med_threshold"`
	HighThreshold byte `json:"high_threshold"`
}

type FlagsResource struct {
	AuthRequired  bool `json:"auth_required"`
	AuthRevocable bool `json:"auth_revocable"`
}

// NewAccountRsource creates a new AccountResource from a provided db.CoreAccountRecord and
// a provided db.AccountRecord.
//
// panics if the two records are not for the same logical account.
func NewAccountResource(ac db.AccountRecord) AccountResource {

	address := ac.Address
	self := fmt.Sprintf("/accounts/%s", address)

	balances := make([]BalanceResource, len(ac.Trustlines)+1)

	for i, tl := range ac.Trustlines {
		balance := BalanceResource{
			Balance: AmountToString(tl.Balance),
			Limit:   AmountToString(tl.Tlimit),
			Issuer:  tl.Issuer,
			Code:    tl.Assetcode,
		}

		switch tl.Assettype {
		case int32(xdr.AssetTypeAssetTypeCreditAlphanum4):
			balance.Type = "credit_alphanum4"
		case int32(xdr.AssetTypeAssetTypeCreditAlphanum12):
			balance.Type = "credit_alphanum12"
		}

		balances[i] = balance
	}

	// add native balance
	balances[len(ac.Trustlines)] = BalanceResource{Type: "native", Balance: AmountToString(ac.Balance)}

	// thresholds
	var thresholds ThresholdsResource
	xdrThresholds, err := ac.DecodeThresholds()
	if err == nil {
		thresholds = ThresholdsResource{
			LowThreshold: xdrThresholds[1],
			MedThreshold: xdrThresholds[2],
			HighThreshold: xdrThresholds[3],
		}
	}

	// signers
	signers := make([]SignerResource, len(ac.Signers)+1)

	for i, s := range ac.Signers {
		signers[i] = SignerResource{Address: s.Publickey, Weight: s.Weight}
	}

	signers[len(ac.Signers)] = SignerResource{Address: ac.Address, Weight: int32(xdrThresholds[0])}

	// flags
	flags := FlagsResource{
		AuthRequired: ac.IsAuthRequired(),
		AuthRevocable: ac.IsAuthRevocable(),
	}

	return AccountResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "%s/transactions/%s", self, hal.StandardPagingOptions).
			Link("operations", "%s/operations/%s", self, hal.StandardPagingOptions).
			Link("effects", "%s/effects/%s", self, hal.StandardPagingOptions).
			Link("offers", "%s/offers/%s", self, hal.StandardPagingOptions),
		ID:                   address,
		PagingToken:          ac.PagingToken(),
		Address:              address,
		Sequence:             ac.Seqnum,
		SubentryCount:        ac.Numsubentries,
		InflationDestination: ac.Inflationdest,
		HomeDomain:           ac.HomeDomain,
		Thresholds:           thresholds,
		Flags:                flags,
		Balances:             balances,
		Signers:              signers,
	}
}

func AmountToString(amount int64) string {
	whole := amount / stellarbase.One
	frac := amount % stellarbase.One
	return fmt.Sprintf("%d.%07d", whole, frac)
}
