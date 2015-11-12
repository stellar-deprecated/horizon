package effects

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

var TypeNames = map[int32]string{
	db.EffectAccountCreated:           "account_created",
	db.EffectAccountRemoved:           "account_removed",
	db.EffectAccountCredited:          "account_credited",
	db.EffectAccountDebited:           "account_debited",
	db.EffectAccountThresholdsUpdated: "account_thresholds_updated",
	db.EffectAccountHomeDomainUpdated: "account_home_domain_updated",
	db.EffectAccountFlagsUpdated:      "account_flags_updated",
	db.EffectSignerCreated:            "signer_created",
	db.EffectSignerRemoved:            "signer_removed",
	db.EffectSignerUpdated:            "signer_updated",
	db.EffectTrustlineCreated:         "trustline_created",
	db.EffectTrustlineRemoved:         "trustline_removed",
	db.EffectTrustlineUpdated:         "trustline_updated",
	db.EffectTrustlineAuthorized:      "trustline_authorized",
	db.EffectTrustlineDeauthorized:    "trustline_deauthorized",
	db.EffectOfferCreated:             "offer_created",
	db.EffectOfferRemoved:             "offer_removed",
	db.EffectOfferUpdated:             "offer_updated",
	db.EffectTrade:                    "trade",
}

func New(row db.EffectRecord) (result hal.Pageable, err error) {
	switch row.Type {
	case db.EffectAccountCreated:
		var e AccountCreated
		err = e.Populate(row)
		result = e
	default:
		var e Base
		e.Populate(row)
		result = e
	}
	return
}

type Base struct {
	Links struct {
		Operation hal.Link `json:"operation"`
		Succeeds  hal.Link `json:"succeeds"`
		Precedes  hal.Link `json:"precedes"`
	} `json:"_links"`

	ID      string `json:"id"`
	PT      string `json:"paging_token"`
	Account string `json:"account"`
	Type    string `json:"type"`
	TypeI   int32  `json:"type_i"`
}

type AccountCreated struct {
	Base
	StartingBalance string `json:"starting_balance"`
}
