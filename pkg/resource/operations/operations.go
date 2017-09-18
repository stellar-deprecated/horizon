package operations

import (
	"time"

	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/render/hal"
	"github.com/stellar/horizon/pkg/resource/base"
	"golang.org/x/net/context"
)

// TypeNames maps from operation type to the string used to represent that type
// in horizon's JSON responses
var TypeNames = map[xdr.OperationType]string{
	xdr.OperationTypeCreateAccount:      "create_account",
	xdr.OperationTypePayment:            "payment",
	xdr.OperationTypePathPayment:        "path_payment",
	xdr.OperationTypeManageOffer:        "manage_offer",
	xdr.OperationTypeCreatePassiveOffer: "create_passive_offer",
	xdr.OperationTypeSetOptions:         "set_options",
	xdr.OperationTypeChangeTrust:        "change_trust",
	xdr.OperationTypeAllowTrust:         "allow_trust",
	xdr.OperationTypeAccountMerge:       "account_merge",
	xdr.OperationTypeInflation:          "inflation",
	xdr.OperationTypeManageData:         "manage_data",
}

// New creates a new operation resource, finding the appropriate type to use
// based upon the row's type.
func New(
	ctx context.Context,
	row history.Operation,
	ledger history.Ledger,
) (result hal.Pageable, err error) {

	base := Base{}
	base.Populate(ctx, row, ledger)

	switch row.Type {
	case xdr.OperationTypeCreateAccount:
		e := CreateAccount{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypePayment:
		e := Payment{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypePathPayment:
		e := PathPayment{}
		e.Payment.Base = base
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeManageOffer:
		e := ManageOffer{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeCreatePassiveOffer:
		e := CreatePassiveOffer{}
		e.ManageOffer.Base = base
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeSetOptions:
		e := SetOptions{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeChangeTrust:
		e := ChangeTrust{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeAllowTrust:
		e := AllowTrust{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeAccountMerge:
		e := AccountMerge{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeInflation:
		e := Inflation{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	case xdr.OperationTypeManageData:
		e := ManageData{Base: base}
		err = row.UnmarshalDetails(&e)
		result = e
	default:
		result = base
	}

	return
}

// Base represents the common attributes of an operation resource
type Base struct {
	Links struct {
		Self        hal.Link `json:"self"`
		Transaction hal.Link `json:"transaction"`
		Effects     hal.Link `json:"effects"`
		Succeeds    hal.Link `json:"succeeds"`
		Precedes    hal.Link `json:"precedes"`
	} `json:"_links"`

	ID              string    `json:"id"`
	PT              string    `json:"paging_token"`
	SourceAccount   string    `json:"source_account"`
	Type            string    `json:"type"`
	TypeI           int32     `json:"type_i"`
	LedgerCloseTime time.Time `json:"created_at"`
	TransactionHash string    `json:"transaction_hash"`
}

// CreateAccount is the json resource representing a single operation whose type
// is CreateAccount.
type CreateAccount struct {
	Base
	StartingBalance string `json:"starting_balance"`
	Funder          string `json:"funder"`
	Account         string `json:"account"`
}

// Payment is the json resource representing a single operation whose type is
// Payment.
type Payment struct {
	Base
	base.Asset
	From   string `json:"from"`
	To     string `json:"to"`
	Amount string `json:"amount"`
}

// PathPayment is the json resource representing a single operation whose type
// is PathPayment.
type PathPayment struct {
	Payment
	Path              []base.Asset `json:"path"`
	SourceMax         string       `json:"source_max"`
	SourceAssetType   string       `json:"source_asset_type"`
	SourceAssetCode   string       `json:"source_asset_code,omitempty"`
	SourceAssetIssuer string       `json:"source_asset_issuer,omitempty"`
}

// ManageData represents a ManageData operation as it is serialized into json
// for the horizon API.
type ManageData struct {
	Base
	Name  string `json:"name"`
	Value string `json:"value"`
}

// ManageOffer is the json resource representing a single operation whose type
// is ManageOffer.
type ManageOffer struct {
	Base
	OfferID            int64      `json:"offer_id"`
	Amount             string     `json:"amount"`
	Price              string     `json:"price"`
	PriceR             base.Price `json:"price_r"`
	BuyingAssetType    string     `json:"buying_asset_type"`
	BuyingAssetCode    string     `json:"buying_asset_code,omitempty"`
	BuyingAssetIssuer  string     `json:"buying_asset_issuer,omitempty"`
	SellingAssetType   string     `json:"selling_asset_type"`
	SellingAssetCode   string     `json:"selling_asset_code,omitempty"`
	SellingAssetIssuer string     `json:"selling_asset_issuer,omitempty"`
}

// CreatePassiveOffer is the json resource representing a single operation whose
// type is CreatePassiveOffer.
type CreatePassiveOffer struct {
	ManageOffer
}

// SetOptions is the json resource representing a single operation whose type is
// SetOptions.
type SetOptions struct {
	Base
	HomeDomain    string `json:"home_domain,omitempty"`
	InflationDest string `json:"inflation_dest,omitempty"`

	MasterKeyWeight *int   `json:"master_key_weight,omitempty"`
	SignerKey       string `json:"signer_key,omitempty"`
	SignerWeight    *int   `json:"signer_weight,omitempty"`

	SetFlags    []int    `json:"set_flags,omitempty"`
	SetFlagsS   []string `json:"set_flags_s,omitempty"`
	ClearFlags  []int    `json:"clear_flags,omitempty"`
	ClearFlagsS []string `json:"clear_flags_s,omitempty"`

	LowThreshold  *int `json:"low_threshold,omitempty"`
	MedThreshold  *int `json:"med_threshold,omitempty"`
	HighThreshold *int `json:"high_threshold,omitempty"`
}

// ChangeTrust is the json resource representing a single operation whose type
// is ChangeTrust.
type ChangeTrust struct {
	Base
	base.Asset
	Limit   string `json:"limit"`
	Trustee string `json:"trustee"`
	Trustor string `json:"trustor"`
}

// AllowTrust is the json resource representing a single operation whose type is
// AllowTrust.
type AllowTrust struct {
	Base
	base.Asset
	Trustee   string `json:"trustee"`
	Trustor   string `json:"trustor"`
	Authorize bool   `json:"authorize"`
}

// AccountMerge is the json resource representing a single operation whose type
// is AccountMerge.
type AccountMerge struct {
	Base
	Account string `json:"account"`
	Into    string `json:"into"`
}

// Inflation is the json resource representing a single operation whose type is
// Inflation.
type Inflation struct {
	Base
}
