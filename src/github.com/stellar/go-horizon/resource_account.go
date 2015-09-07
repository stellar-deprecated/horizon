package horizon

import (
	"fmt"
	"strings"
	"encoding/base64"

	"github.com/guregu/null"
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

// AccountResource is the summary of an account
type AccountResource struct {
	halgo.Links
	ID            string             `json:"id"`
	PagingToken   string             `json:"paging_token"`
	Address       string             `json:"address"`
	Sequence      int64              `json:"sequence"`
	Numsubentries int32              `json:"numsubentries"`
	InflationDest null.String        `json:"inflation_destination"`
	HomeDomain    null.String        `json:"home_domain"`
	Thresholds    map[string]byte    `json:"thresholds"`
	Flags         map[string]bool    `json:"flags"`
	Balances      []BalanceResource  `json:"balances"`
	Signers       []SignerResource   `json:"signers"`
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

	// signers
	signers := make([]SignerResource, len(ac.Signers))

	for i, s := range ac.Signers {
		signers[i] = SignerResource{Address: s.Publickey, Weight: s.Weight}
	}

	// thresholds
	reader := strings.NewReader(ac.Thresholds)
	b64r := base64.NewDecoder(base64.StdEncoding, reader)
	var xdrThresholds xdr.Thresholds
	_, err := xdr.Unmarshal(b64r, &xdrThresholds)

	var thresholdsMap map[string]byte
	if err == nil {
		thresholdsMap = make(map[string]byte)
		thresholdsMap["threshold_master_weight"] = xdrThresholds[0]
		thresholdsMap["threshold_low"] = xdrThresholds[1]
		thresholdsMap["threshold_med"] = xdrThresholds[2]
		thresholdsMap["threshold_high"] = xdrThresholds[3]
	}

	// flags
	flagsMap := make(map[string]bool)
	flagsMap["auth_required_flag"] = IsTrue(ac.Flags & 1)
	flagsMap["auth_revocable_flag"] = IsTrue(ac.Flags & 2)

	return AccountResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "%s/transactions/%s", self, hal.StandardPagingOptions).
			Link("operations", "%s/operations/%s", self, hal.StandardPagingOptions).
			Link("effects", "%s/effects/%s", self, hal.StandardPagingOptions).
			Link("offers", "%s/offers/%s", self, hal.StandardPagingOptions),
		ID:            address,
		PagingToken:   ac.PagingToken(),
		Address:       address,
		Sequence:      ac.Seqnum,
		Numsubentries: ac.Numsubentries,
		InflationDest: ac.Inflationdest,
		HomeDomain:    ac.HomeDomain,
		Thresholds:    thresholdsMap,
		Flags:         flagsMap,
		Balances:      balances,
		Signers:       signers,
	}
}

func AmountToString(amount int64) string {
	whole := amount / stellarbase.One
	frac := amount % stellarbase.One
	return fmt.Sprintf("%d.%07d", whole, frac)
}

func IsTrue(value int32) bool {
  if value != 0 {
    return true
  }
  return false
}
