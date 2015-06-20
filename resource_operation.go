package horizon

import (
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-stellar-base/xdr"
)

var operationResourceTypeNames = map[xdr.OperationType]string{
	xdr.OperationTypeCreateAccount:      "create_account",
	xdr.OperationTypePayment:            "payment",
	xdr.OperationTypePathPayment:        "path_payment",
	xdr.OperationTypeManageOffer:        "manage_offer",
	xdr.OperationTypeCreatePassiveOffer: "create_passive_offer",
	xdr.OperationTypeSetOption:          "set_options",
	xdr.OperationTypeChangeTrust:        "change_trust",
	xdr.OperationTypeAllowTrust:         "allow_trust",
	xdr.OperationTypeAccountMerge:       "account_merge",
	xdr.OperationTypeInflation:          "inflation",
}

// OperationResource is the json form of a row from the history_operations
// table.
type OperationResource map[string]interface{}

// NewOperationResource initializes a new resource from an OperationRecord
func NewOperationResource(op db.OperationRecord) (OperationResource, error) {
	result, err := op.Details()

	if err != nil {
		return nil, err
	}

	if result == nil {
		result = make(map[string]interface{})
	}

	self := fmt.Sprintf("/operations/%d", op.Id)

	result["_links"] = halgo.Links{}.
		Self(self).
		Link("transactions", "/transactions/%d", op.TransactionId).
		Link("effects", "%s/effects/%s", self, hal.StandardPagingOptions).
		Link("precedes", "/operations?cursor=%s&order=asc", op.PagingToken()).
		Link("succeeds", "/operations?cursor=%s&order=desc", op.PagingToken()).
		Items
	result["id"] = op.Id
	result["paging_token"] = op.PagingToken()
	result["type"] = op.Type

	ts, ok := operationResourceTypeNames[op.Type]

	if ok {
		result["type_s"] = ts
	} else {
		result["type_s"] = "unknown"
	}

	return result, nil
}

// NewOperationResourcePage initialzed a hal.Page from s a slice of
// OperationRecords
func NewOperationResourcePage(records []db.OperationRecord, query db.PageQuery, path string) (hal.Page, error) {
	fmts := path + "?order=%s&limit=%d&cursor=%s"
	next, prev, err := query.GetContinuations(records)
	if err != nil {
		return hal.Page{}, err
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		r, err := NewOperationResource(record)
		if err != nil {
			return hal.Page{}, err
		}
		resources[i] = r
	}

	return hal.Page{
		Links: halgo.Links{}.
			Self(fmts, query.Order, query.Limit, query.Cursor).
			Link("next", fmts, next.Order, next.Limit, next.Cursor).
			Link("prev", fmts, prev.Order, prev.Limit, prev.Cursor),
		Records: resources,
	}, nil
}
