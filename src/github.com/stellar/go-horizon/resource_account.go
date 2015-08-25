package horizon

import (
	"fmt"

	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-stellar-base/xdr"
)

// AccountResource is the summary of an account
type AccountResource struct {
	halgo.Links
	ID          string            `json:"id"`
	PagingToken string            `json:"paging_token"`
	Address     string            `json:"address"`
	Sequence    int64             `json:"sequence"`
	Balances    []BalanceResource `json:"balances"`
}

// BalanceResource represents an accounts holdings for a single currency type
type BalanceResource struct {
	Type    string `json:"asset_type"`
	Balance int64  `json:"balance"`
	// additional trustline data
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"issuer,omitempty"`
	Limit  int64  `json:"limit,omitempty"`
}

// NewAccountResource creates a new AccountResource from a provided db.CoreAccountRecord and
// a provided db.AccountRecord.
//
// panics if the two records are not for the same logical account.
func NewAccountResource(ac db.AccountRecord) AccountResource {

	address := ac.Address
	self := fmt.Sprintf("/accounts/%s", address)

	balances := make([]BalanceResource, len(ac.Trustlines)+1)

	for i, tl := range ac.Trustlines {
		balance := BalanceResource{
			Balance: tl.Balance,
			Limit:   tl.Tlimit,
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
	balances[len(ac.Trustlines)] = BalanceResource{Type: "native", Balance: ac.Balance}

	return AccountResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "%s/transactions/%s", self, hal.StandardPagingOptions).
			Link("operations", "%s/operations/%s", self, hal.StandardPagingOptions).
			Link("effects", "%s/effects/%s", self, hal.StandardPagingOptions).
			Link("offers", "%s/offers/%s", self, hal.StandardPagingOptions),
		ID:          address,
		PagingToken: ac.PagingToken(),
		Address:     address,
		Sequence:    ac.Seqnum,
		Balances:    balances,
	}
}
