package horizon

import (
	"fmt"

	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
)

// AccountResource is the summary of an account
type AccountResource struct {
	halgo.Links
	Id          string            `json:"id"`
	PagingToken string            `json:"paging_token"`
	Address     string            `json:"address"`
	Sequence    int64             `json:"sequence"`
	Balances    []BalanceResource `json:"balances"`
}

// BalanceResource represents an accounts holdings for a single currency type
type BalanceResource struct {
	Type    string `json:"currency_type"`
	Balance int64  `json:"balance"`
	// additional trustline data
	Code   string `json:"currency_code,omitempty"`
	Issuer string `json:"currency_issuer,omitempty"`
	Limit  int64  `json:"limit,omitempty"`
}

// NewAccountResource creates a new AccountResource from a provided db.CoreAccountRecord and
// a provided db.AccountRecord.
//
// panics if the two records are not for the same logical account.
func NewAccountResource(ac db.AccountRecord) AccountResource {

	address := ac.Address
	self := fmt.Sprintf("/accounts/%s", address)
	po := "{?cursor}{?limit}{?order}"

	balances := make([]BalanceResource, len(ac.Trustlines)+1)

	for i, tl := range ac.Trustlines {
		balances[i] = BalanceResource{
			Type:    "alphanum",
			Balance: tl.Balance,
			Code:    tl.Alphanumcurrency,
			Issuer:  tl.Issuer,
			Limit:   tl.Tlimit,
		}
	}

	// add native balance
	balances[len(ac.Trustlines)] = BalanceResource{Type: "native", Balance: ac.Balance}

	return AccountResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "%s/transactions/%s", self, po).
			Link("operations", "%s/operations/%s", self, po).
			Link("effects", "%s/effects/%s", self, po).
			Link("offers", "%s/offers/%s", self, po),
		Id:          address,
		PagingToken: ac.PagingToken(),
		Address:     address,
		Sequence:    ac.Seqnum,
		Balances:    balances,
	}
}
